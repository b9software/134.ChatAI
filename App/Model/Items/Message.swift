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
        case me = "user"  // swiftlint:disable:this identifier_name
        case assistant
    }

    enum MState: Int16, CustomStringConvertible {
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

        var couldRetry: Bool {
            switch self {
            case .froze, .error:
                return true
            default:
                return false
            }
        }

        var description: String {
            switch self {
            case .bad: return ".bad"
            case .normal: return ".normal"
            case .pend: return ".pend"
            case .froze: return ".froze"
            case .error: return ".error"
            }
        }
    }

    let id: UUID
    let entity: CDMessage
    private(set) var type: MType
    private(set) var role: MRole?
    private(set) var state: MState {
        didSet {
            assertDispatch(.notOnQueue(.main))
            entity.mState = state
        }
    }
    private(set) var time: Date

    private init(entity: CDMessage) {
        id = entity.uid
        type = entity.mType
        role = entity.mRole
        state = entity.mState
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
            Current.database.save { [self] _ in
                if let err = senderState?.error {
                    AppLog().warning("Message send error: \(err.localizedDescription).")
                    state = .error
                } else if senderState == nil {
                    // 发送成功
                    if entity.content == nil {
                        assert(false)
                        state = .error
                    } else {
                        state = .normal
                    }
                    assert(entity.text != nil)
                }
                needsNoticeStateChange.set()
            }
        }
    }
    func setNoSteamSending() {
        var state = senderState ?? SenderState(isSending: false, noSteam: true)
        senderState = state
    }
    func waitSendFinshed() async throws {
        assert(senderState != nil)
        let task = Task {
            let start = Date()
            while true {
                AppLog().debug("waitSendFinshed")
                debugPrint(senderState)
                if let err = senderState?.error {
                    throw err
                }
                if senderState?.isSending == false || senderState == nil {
                    return
                }
                if start.timeIntervalSinceNow < -25 {
                    throw AppError.message("Wait message finish timeout.")
                }
                try await Task.sleep(nanoseconds: 100_000_000)
            }
        }
        try await task.value
    }

    private(set) lazy var delegates = MulticastDelegate<MessageUpdating>()
    private lazy var needsNoticeStateChange = DelayAction(Action { [weak self] in
        guard let sf = self else { return }
        sf.delegates.invoke { $0.messageStateUpdate(sf) }
    })
    private lazy var needsNoticeDetailReady = DelayAction(Action { [weak self] in
        guard let sf = self else { return }
        sf.delegates.invoke { $0.messageDetailReady(sf) }
    })
}

extension Message {
    static func create(sendText: String, from chatItem: Conversation, reply: Message?) {
        // todo: 出错了得通知用户
        Current.database.save { ctx in
            let chatID = chatItem.entity.objectID
            let replyID = reply?.entity.objectID
            let myEntity = try CDMessage.createEntities(ctx, conversation: chatID, reply: replyID).0
            myEntity.mType = .text
            myEntity.text = sendText
            chatItem.entity.lastTime = .current
        }
    }

    static func createMessage(sendText: String, from chatItem: Conversation, reply: Message?, noSteam: Bool) async throws -> Message {
        try await Current.database.read { ctx in
            let chatID = chatItem.entity.objectID
            let replyID = reply?.entity.objectID
            let (myEntity, newEntity) = try CDMessage.createEntities(ctx, conversation: chatID, reply: replyID)
            myEntity.mType = .text
            myEntity.text = sendText
            chatItem.entity.lastTime = .current
            let item = Message.from(entity: newEntity)
            if noSteam {
                item.setNoSteamSending()
            }
            try ctx.save()
            return item
        }
    }

    static func continueMessage(_ message: Message) {
        Current.database.save { ctx in
            message.entity.appendContinue(context: ctx)
        }
    }

    func delete() {
        if senderState?.isSending == true {
            stopResponse()
        }
        Current.database.save { [self] ctx in
            if state == .pend {
                state = .froze
            }
            entity.deleteTime = .current
        }
    }

    var replySelectionTitle: String {
        (cachedText ?? "Selected Message")
            .trimming(toLength: 20)
            .replacingOccurrences(of: "\n", with: " ")
    }

    func hasNext(_ callback: @escaping (Message, Bool) -> Void) {
        entity.async { entity, _ in
            let has = entity.next != nil
            dispatch_async_on_main {
                callback(self, has)
            }
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
                #if DEBUG
                if AppDelegate().debug.debugMessageTime {
                    let creatDesc = entity.createTime?.localTime ?? "No create"
                    cachedText = "\(entity.text ?? "")\n\(entity.time.localTime)\n\(creatDesc)"
                }
                #endif
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

    func onResponse(oaEntity: OAChatCompletion) throws {
        assertDispatch(.notOnQueue(.main))
        assert(senderState?.isSending == true)
        guard let choice = oaEntity.choices?.first else {
            throw AppError.message("Bad response: choices field is empty.")
        }
        guard let text = choice.message?.content else {
            throw AppError.message("Bad response: No message.content.")
        }
        cachedText = text
        entity.modify { this, _ in
            var content = CDMessageContent()
            if choice.finishReason == "length" {
                content.isEnd = false
            }
            this.text = text
            this.mContent = content
        }
        Task { @MainActor in
            self.delegates.invoke { $0.messageReceiveDeltaReplay(self, text: text) }
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
            Task { @MainActor in
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

    func retry(completion: ((Message) -> Void)?) {
        Current.database.save { [self] _ in
            assert(state != .pend)
            state = .pend
            entity.text = nil
            entity.content = nil
            dispatch_after_seconds(0.1) {
                completion?(self)
            }
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
    /// 状态更新：包括发送/接收状态
    func messageStateUpdate(_ item: Message)
    /// 接收到数据片段
    func messageReceiveDeltaReplay(_ item: Message, text: String)
}

extension MessageUpdating {
    func messageDetailReady(_: Message) {}
    func messageStateUpdate(_ item: Message) {}
    func messageReceiveDeltaReplay(_ item: Message, text: String) {}
}
