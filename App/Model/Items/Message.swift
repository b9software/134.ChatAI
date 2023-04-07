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
    var cachedText: String?

    private(set) lazy var delegates = MulticastDelegate<MessageUpdating>()
    private lazy var needsNoticeDetailReady = DelayAction(Action { [weak self] in
        guard let sf = self else { return }
        sf.delegates.invoke { $0.messageDetailReady(sf) }
    })
}

extension Message {
    static func create(sendText: String, from chatItem: Conversation) {
        let chatID = chatItem.entity.access { $0.objectID }
        Current.database.context.async { ctx in
            let safeChat = ctx.object(with: chatID) as? CDConversation

            let myEntity = CDMessage.createMy(ctx, text: sendText)
            myEntity.conversation = safeChat

            let replyEntity = CDMessage(context: ctx)
            replyEntity.type = MType.changeable.rawValue
            replyEntity.mRole = .assistant
            replyEntity.mState = .pend
            replyEntity.conversation = safeChat

            myEntity.next = replyEntity.uid
            replyEntity.prev = myEntity.uid
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
            return MessageUnsupportedCell.id
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
    func messageDetailReady(_ item: Message)
}

extension MessageUpdating {
    func messageDetailReady(_: Message) {}
}
