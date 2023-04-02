//
//  Conversation.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import B9Action
import B9MulticastDelegate
import CoreData

private let conversationPool = ObjectPool<StringID, Conversation>()

class Conversation {
    let id: StringID
    var entity: CDConversation
    private(set) lazy var delegates = MulticastDelegate<ConversationUpdating>()

    var name: String {
        title ?? L.Chat.defaultTitle
    }
    private var title: String?

    private init(entity: CDConversation) {
        self.id = entity.id!
        self.entity = entity
        title = entity.title
    }

    static func from(entity: CDConversation) -> Conversation {
        conversationPool.object(key: entity.id!, creator: Conversation(entity: entity))
    }

    enum UsableState {
        case normal
        /// Deleted or archived
        case archived
        /// Can view, but must setup before send
        case engineOutdate
        /// After create, must setup before use
        case forceSetup
    }

    private(set) var usableState: UsableState = .normal
    private lazy var needsUpdateUsable = DelayAction(.init(target: self, selector: #selector(updateUsableState)))

    struct ChatConfig: Codable, Equatable {
    }

    struct EngineConfig: Codable, Equatable {
        var model: StringID?
    }

    private var _chatConfig: ChatConfig?
    private var _engineConfig: EngineConfig?
    private var _engine: Engine?
}

extension Conversation {

    @objc private func updateUsableState() {
        let new = calcUsableState()
        if usableState == new { return }
        usableState = new
        delegates.invoke { $0.conversation(self, useState: new) }
    }

    private func calcUsableState() -> UsableState {
        if entity.deleteTime != nil || entity.archiveTime != nil {
            return .archived
        }
        if _engine == nil {
            guard let engineData = entity.engine else {
                return .forceSetup
            }
            _engine = Engine.from(entity: engineData)
        }
        guard let engine = _engine,
              engineConfig.model?.isNotEmpty == true else {
            return .forceSetup
        }
        guard engine.isValid else {
            return .engineOutdate
        }
        return .normal
    }

    var chatConfig: ChatConfig {
        get {
            _chatConfig ?? {
                let config = entity.access { $0.loadChatConfig() } ?? ChatConfig()
                _chatConfig = config
                return config
            }()
        }
        set {
            if _chatConfig == newValue { return }
            _chatConfig = newValue
            entity.modify { this, _ in
                Do.try {
                    this.cSetting = try newValue.encode()
                }
            }
        }
    }

    var engineConfig: EngineConfig {
        get {
            _engineConfig ?? {
                let config = entity.access { $0.loadEngineConfig() } ?? EngineConfig()
                _engineConfig = config
                return config
            }()
        }
        set {
            if _engineConfig == newValue { return }
            _engineConfig = newValue
            entity.modify { this, _ in
                Do.try {
                    this.cSetting = try newValue.encode()
                }
            }
        }
    }
}

// MARK: - Public Operation

extension Conversation {
    func requireUsableState() {
        needsUpdateUsable.set()
    }

    func archive() {
        entity.modify { this, _ in this.archiveTime = .current }
        needsUpdateUsable.set()
    }

    func delete() {
        entity.modify { this, _ in this.deleteTime = .current }
        needsUpdateUsable.set()
    }

    func unarchive() {
        entity.modify { this, _ in this.archiveTime = nil }
        needsUpdateUsable.set()
    }

    func undelete() {
        entity.modify { this, _ in this.deleteTime = nil }
        needsUpdateUsable.set()
    }
}

// MARK: - Feature

extension Conversation: Hashable, ItemTextSearchable {
    static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    func isSearchIncluded(in key: String) -> Bool {
        name.localizedCaseInsensitiveContains(key)
    }
}

// MARK: - 状态通知

protocol ConversationUpdating {
    /// 影响会话列表的状态
    func conversationListStateChanged(_ item: Conversation)

    func conversation(_ item: Conversation, useState: Conversation.UsableState)
}

extension ConversationUpdating {
    func conversationListStateChanged(_ item: Conversation) {}
    func conversation(_ item: Conversation, useState: Conversation.UsableState) {}
}
