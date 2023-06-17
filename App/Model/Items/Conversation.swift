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

struct ChatConfig: Codable, Equatable {
    var draft: String?
    var sendbyKey: Int?
}

struct EngineConfig: Codable, Equatable {
    var model: StringID?
    var system: String?
    var temperature: FloatParameter = 0.5
    /// Tokens top probability
    var topP: FloatParameter = 1
    /// Presence penalty, between -2.0 and 2.0
    var presenceP: FloatParameter = 0.5
    /// Frequency penalty, between -2.0 and 2.0
    var frequencyP: FloatParameter = 0.5
    var choiceNumber = 1
    var maxTokens = 0

    func toOpenAIParameters() throws -> [String: Any] {
        guard let model = model else {
            throw AppError.message("Missing model.")
        }
        var result = [String: Any]()
        result["model"] = model
        if !(0.495...0.505).contains(temperature) {
            result["temperature"] = temperature * 2
        }
        if !(0.99...1).contains(topP) {
            result["top_p"] = topP
        }
        if !(0.495...0.505).contains(presenceP) {
            result["presence_penalty"] = presenceP * 4 - 2
        }
        if !(0.495...0.505).contains(frequencyP) {
            result["frequency_penalty"] = frequencyP * 4 - 2
        }
        if maxTokens > 0 {
            result["max_tokens"] = maxTokens
        }
        return result
    }
}

class Conversation {
    private(set) var id: StringID
    private(set) var entity: CDConversation
    private(set) lazy var delegates = MulticastDelegate<ConversationUpdating>()

    var name: String {
        title ?? L.Chat.defaultTitle
    }
    private(set) var title: String? {
        didSet {
            if oldValue == title { return }
            needsListStateChanged.set()
        }
    }

    private init(entity: CDConversation) {
        self.id = entity.id!
        self.entity = entity
        title = entity.title
        AppLog().debug("Chat> Create conversation instance of \(id).")
    }

    static func from(entity: CDConversation) -> Conversation {
//        assertDispatch(.notOnQueue(.main))
        return conversationPool.object(key: entity.id!, creator: Conversation(entity: entity))
    }

    static func load(id: StringID) async -> Conversation? {
        if let item = conversationPool[id] { return item }
        return await Current.database.read { ctx in
            guard let entity = try? ctx.fetch(CDConversation.request(id: id)).first else {
                return nil
            }
            let item = Conversation.from(entity: entity)
            return item
        }
    }

    static func load(id: StringID, completion: @escaping (Result<Conversation, Error>) -> Void) {
        let cb = Do.safe(callback: completion)
        if let item = conversationPool[id] {
            cb(.success(item))
            return
        }
        Current.database.async { ctx in
            do {
                guard let entity = try ctx.fetch(CDConversation.request(id: id)).first else {
                    throw AppError.message("No conversation with id: \(id).")
                }
                let item = Conversation.from(entity: entity)
                cb(.success(item))
            } catch {
                cb(.failure(error))
            }
        }
    }

    private lazy var needsListStateChanged = DelayAction(.init(target: self, selector: #selector(noticeListStateChanged)))

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

    private var _chatConfig: ChatConfig?
    private var _engineConfig: EngineConfig?
    private(set) var engine: Engine?
}

extension Conversation {
    func loadEngine() async throws -> Engine {
        if let engine = engine { return engine }
        guard let ctx = entity.managedObjectContext else {
            fatalError()
        }
        return try await ctx.perform(schedule: .enqueued) {
            guard let eEntity = self.entity.engine else {
                throw AppError.message(L.Chat.Send.engineNotSet)
            }
            guard let eItem = Engine.from(entity: eEntity) else {
                throw AppError.message(L.Chat.Send.engineNoLoad)
            }
            self.engine = eItem
            return eItem
        }
    }

    @objc private func updateUsableState() {
        entity.async { [self] _, _ in
            let new: UsableState = calcUsableState()
            if usableState == new { return }
            usableState = new
            dispatch_async_on_main {
                self.delegates.invoke { $0.conversation(self, useState: new) }
            }
        }
    }

    private func calcUsableState() -> UsableState {
        if entity.deleteTime != nil || entity.archiveTime != nil {
            return .archived
        }
        if engine == nil {
            guard let engineData = entity.engine else {
                return .forceSetup
            }
            engine = Engine.from(entity: engineData)
        }
        guard let engine = engine else {
            return .forceSetup
        }
        if engine.hasModels {
            guard engineConfig.model?.isNotEmpty == true else {
                return .forceSetup
            }
        }
        guard engine.isValid else {
            return .engineOutdate
        }
        return .normal
    }

    func loadDraft(toView: ChatTextView) {
        Current.database.async { [self] _ in
            var config = chatConfig
            guard let text = config.draft else {
                return
            }
            config.draft = nil
            chatConfig = config
            Task { @MainActor in
                if toView.text.trimmed() == nil {
                    toView.draftText = text
                }
            }
        }
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
                    this.eSetting = try newValue.encode()
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

    func clearMessage() {
        Current.database.save { [self] ctx in
            entity.messages?.forEach {
                if let mEntity = $0 as? CDMessage {
                    ctx.delete(mEntity)
                }
            }
            try ctx.save()
        }
        Current.database.async { [self] _ in
            assert(entity.messages?.count == 0)
        }
    }

    func send(text: String, reply: Message?) {
        Message.create(sendText: text, from: self, reply: reply)
    }

    func save(name: String?, id: String?, engine: Engine, cfgChat: ChatConfig, cfgEngine: EngineConfig) async throws {
        let newID = id ?? self.id
        guard await entity.isNewIDAvailable(newID: newID) else {
            throw AppError.message(L.Chat.Setting.badSameID)
        }
        if self.id != newID {
            conversationPool.updateObjectKey(from: self.id, to: newID)
            self.id = newID
        }
        if let model = cfgEngine.model {
            engine.lastSelectedModel = model
        }
        engine.updateUsedTime()
        self.engine = engine
        title = name
        chatConfig = cfgChat
        engineConfig = cfgEngine
        entity.modify { this, _ in
            this.id = newID
            this.title = name
            this.updateTime = .current
            this.engine = engine.entity
        }
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

extension Conversation {
    @objc private func noticeListStateChanged() {
        delegates.invoke { $0.conversationListStateChanged(self) }
    }
}

protocol ConversationUpdating {
    /// 影响会话列表的状态
    func conversationListStateChanged(_ item: Conversation)

    func conversation(_ item: Conversation, useState: Conversation.UsableState)
}

extension ConversationUpdating {
    func conversationListStateChanged(_ item: Conversation) {}
    func conversation(_ item: Conversation, useState: Conversation.UsableState) {}
}
