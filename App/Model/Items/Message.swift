//
//  Message.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import B9Action
import B9MulticastDelegate
import CoreData

private let messagePool = ObjectPool<UUID, Message>()

/// 写入都在后台线程
class Message {
    enum MType: Int16, CustomStringConvertible {
        /// 异常或不识别
        case bad = 0
        /// 简单的纯文字消息
        case text = 1

        /// 组，一条消息包括多个版本
        /// 聚合，多个引擎

        /// 待接收消息未收到时使用，等收到足够信息后变为其他类型
        case changeable = 63

        var description: String {
            switch self {
            case .bad: return ".bad"
            case .text: return ".text"
            case .changeable: return ".changeable"
            }
        }
    }

    enum MRole: String {
        case me = "user"
        case assistant
    }

    enum MState: Int16 {
        /// 异常或不识别
        case bad = 0
        /// 状态良好，不需要任何操作
        case normal = 1
        /// 等待完成
        case pend = 2
        /// 发现创建完成后较久仍未完成设置，不再自动请求，需用户需要手动点击
        case froze = 4
        /// 出错了
        case error = 9
    }

    let id: UUID
    private(set) var type: MType
    private(set) var role: MRole?
    let entity: CDMessage
    var time: Date

    private init(entity: CDMessage) {
        id = entity.uid
        type = entity.mType
        role = entity.mRole
        time = entity.time
        self.entity = entity
        // 其他属性异步加载
    }

    static func from(entity: CDMessage) -> Message {
        messagePool.object(key: entity.uid, creator: Message(entity: entity))
    }

    // 缓存内容
    private(set) var cachedText: String?
    private(set) weak var conversation: Conversation?

    /// MessageSender 专用
    var senderState: SenderState? {
        didSet {
            if oldValue == senderState { return }
            needsNoticeSendStateChange.set()
            if let err = senderState?.error {
                AppLog().warning("Message send error: \(err.localizedDescription).")
                entity.modify { this, _ in
                    this.mState = .error
                }
            } else if senderState == nil {
                entity.modify { this, _ in
                    assert(this.text != nil)
                    assert(this.content != nil)
                    this.mState = .normal
                }
            }
        }
    }

    private(set) lazy var delegates = MulticastDelegate<MessageUpdating>()
    private lazy var needsNoticeSendStateChange = DelayAction(Action { [weak self] in
        guard let sf = self else { return }
        sf.delegates.invoke { $0.messageSendStateChanged(sf) }
    })
    private lazy var needsNoticeDetailReady = DelayAction(Action { [weak self] in
        guard let sf = self else { return }
        sf.delegates.invoke { $0.messageDetailReady(sf) }
    })
}

extension Message {
    static func create(sendText: String, from chatItem: Conversation, reply: Message?) {
        // TODO: 出错了得通知用户
        Current.database.context.async { ctx in
            let chatID = chatItem.entity.access { $0.objectID }
            let replyID = reply?.entity.access { $0.objectID }
            let myEntity = try CDMessage.createEntities(ctx, conversation: chatID, reply: replyID)
            myEntity.mType = .text
            myEntity.text = sendText
        }
    }

    /// 是否立即可用
    func fetchDetail() -> Bool {
        switch type {
        case .text:
            if cachedText != nil { return true }
        case .bad, .changeable:
            return true
        }
        startFetchDetail()
        return false
    }

    private func startFetchDetail() {
        entity.managedObjectContext?.perform { [self] in
            switch type {
            case .text:
                cachedText = entity.text
            default:
                break
            }
            needsNoticeDetailReady.set()
        }
    }

    func loadConversation() async throws -> Conversation {
        if let conversation = conversation { return conversation }
        guard let ctx = entity.managedObjectContext else {
            fatalError()
        }
        return try await ctx.perform(schedule: .enqueued) { [self] in
            guard let chatEntity = self.entity.conversation else {
                throw AppError.message("\(self) no conversation.")
            }
            return Conversation.from(entity: chatEntity)
        }
    }

    func onSteamResponse(_ choice: OAChatCompletion.Choice) {
        assertDispatch(.notOnQueue(.main))
        assert(senderState?.isSending == true)
        guard let delta = choice.delta else {
            AppLog().warning("choice.delta should not be nil.")
            return
        }
        if let value = delta.role {
            assert(value == .assistant)
            // 开始接收
            cachedText = ""
        }
        if let content = delta.content {
            assert(cachedText != nil)
            cachedText?.append(contentsOf: content)
            AppLog().debug("Reviving in message: \(content).")
            dispatch_sync_on_main {
                self.delegates.invoke { $0.messageReceiveDeltaReplay(self, text: content) }
            }
        }
        if let finished = choice.finishReason {
            entity.modify { this, _ in
                var content = this.mContent ?? CDMessageContent()
                if finished == "length" {
                    content.isEnd = false
                } else {
                    assert(finished == "stop")
                }
                this.text = self.cachedText
                this.mContent = content
            }
            needsNoticeDetailReady.set()
        }
    }

    func stopResponse() {
        Task {
            await Current.messageSender.stop(message: self)
        }
    }
}

extension Message: Hashable, ListItem, CustomDebugStringConvertible {
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    func cellIdentifier(for: UITableView, indexPath: IndexPath) -> String {
        if role == .me {
            if type == .text { return MessageMyTextCell.id }
        } else if role == .assistant {
            if type == .changeable {
                return MessageUnsupportedCell.id
            } else if type == .text {
                return MessageTextCell.id
            }
        }
        return MessageUnsupportedCell.id
    }

    var debugDescription: String {
        "<Message: \(id), \(time)>"
    }
}

// MARK: - 状态通知

extension Message {

}

protocol MessageUpdating {
    /// 数据已从数据库加载完毕，可以显示了
    func messageDetailReady(_ item: Message)
    /// 发送/接收状态更新
    func messageSendStateChanged(_ item: Message)
    /// 接收到数据片段
    func messageReceiveDeltaReplay(_ item: Message, text: String)
}

extension MessageUpdating {
    func messageDetailReady(_: Message) {}
    func messageSendStateChanged(_ item: Message) {}
    func messageReceiveDeltaReplay(_ item: Message, text: String) {}
}
