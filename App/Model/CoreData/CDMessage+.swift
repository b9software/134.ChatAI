//
//  CDMessage+.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import CoreData

public extension CDMessage {
    override func awakeFromInsert() {
        super.awakeFromInsert()
        uid = UUID()
        let now = Date.current
        time = now
        createTime = now
        updateTime = now
    }

    override func awakeFromFetch() {
        super.awakeFromFetch()
        if uid == nil {
            uid = UUID()
            AppLog().warning("CD> Add missing id to a CDMessage.")
        }
        #if DEBUG
        if time == nil {
            AppLog().critical("CD> Missing time: \(self).")
        }
        if createTime == nil {
            AppLog().warning("CD> Missing createTime: \(self).")
        }
        if by == nil {
            AppLog().critical("CD> Missing by: \(self).")
        }
        if state == 0 {
            AppLog().critical("CD> Bad state: \(self).")
        }
        #endif
    }

    /// 纯操作，不涉及线程
    func delete(_ ctx: NSManagedObjectContext) {
        if parent == nil {
            // 自身是 parent
            ctx.delete(self)
            // 更新下属
            return
        } else {
            // 链表中的一环
            // 找上下接起来
        }
    }
}

extension CDMessage {
    static let createTimeKey = #keyPath(CDMessage.createTime)
    static let conversationKey = #keyPath(CDMessage.conversation)
    static let deleteTimeKey = #keyPath(CDMessage.deleteTime)
    static let parentKey = #keyPath(CDMessage.parent)
    static let stateKey = #keyPath(CDMessage.state)
    static let timeKey = #keyPath(CDMessage.time)

    /// 消息列表
    static func conversationRequest(_ chatEntity: CDConversation, offset: Int, limit: Int, ascending: Bool) -> NSFetchRequest<CDMessage> {
        let request = fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: timeKey, ascending: false),
        ]
        request.fetchOffset = offset
        request.fetchLimit = limit
        request.predicate = NSPredicate(
            format: "%K == %@ AND %K == nil",
            conversationKey, chatEntity,
            deleteTimeKey
        )
        return request
    }

    /// 待发送消息
    static func pendingRequest() -> NSFetchRequest<CDMessage> {
        let request = fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: timeKey, ascending: true),
        ]
        request.predicate = NSPredicate(format: "%K == %d", stateKey, Message.MState.pend.rawValue)
        return request
    }

    static func childRequest(parent: CDMessage) -> NSFetchRequest<CDMessage> {
        let request = fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: createTimeKey, ascending: false),
        ]
        request.predicate = NSPredicate(
            format: "%K == %@ AND %K == nil",
            parentKey, parent,
            deleteTimeKey
        )
        return request
    }
}

struct CDMessageContent: Codable {
    /// 消息已全部接收完成，没有被长度限制
    var isEnd = true
}

extension CDMessage: ModelValidate {
    /// 空是不识别，不应显示
    var mType: Message.MType {
        get { .init(rawValue: type) ?? .bad }
        set { type = newValue.rawValue }
    }

    var mRole: Message.MRole? {
        get { .init(rawValue: by) }
        set { by = newValue?.rawValue }
    }

    var mState: Message.MState {
        get { .init(rawValue: state) ?? .bad }
        set {
            if newValue == .bad { return }
            state = newValue.rawValue
        }
    }

    var mContent: CDMessageContent? {
        get {
            guard let data = content else { return nil }
            return Do.try {
                try CDMessageContent.decode(data)
            }
        }
        set {
            Do.try {
                content = try newValue?.encode()
            }
        }
    }

    func validate() throws {
        if mType == .bad {
            throw AppError.message("Bad type")
        }
        if mState == .bad {
            throw AppError.message("Bad state")
        }
    }

    func buildContext() async throws -> [OAChatMessage] {
        try await Current.database.read { [self] ctx in
            let parent = parent ?? self
            var messages = try ctx.fetch(Self.childRequest(parent: parent))
            messages.insert(parent, at: 0)
            let result: [OAChatMessage] = messages.compactMap { entity in
                guard entity.mType == .text,
                      let value = entity.text else {
                    return nil
                }
                switch entity.mRole {
                case .me:
                    return OAChatMessage(role: .user, content: value)
                case .assistant:
                    return OAChatMessage(role: .assistant, content: value)
                case .none:
                    return nil
                }
            }
            return result
        }
    }

    /// 返回未设置内容的我的消息，
    static func createEntities(_ ctx: NSManagedObjectContext, conversation: NSManagedObjectID, reply: NSManagedObjectID?) throws -> CDMessage {
        guard let safeChat = ctx.object(with: conversation) as? CDConversation else {
            throw AppError.message("Unable get conversation entity.")
        }
        assert(reply == nil, "todo")
        let myEntity = CDMessage(context: ctx)
        myEntity.mRole = .me
        myEntity.mState = .normal
        myEntity.conversation = safeChat

        let replyEntity = CDMessage(context: ctx)
        replyEntity.mType = .text
        replyEntity.mRole = .assistant
        replyEntity.mState = .pend
        replyEntity.conversation = safeChat
        replyEntity.parent = myEntity

        myEntity.next = replyEntity.uid
        myEntity.prev = replyEntity.uid
        replyEntity.prev = myEntity.uid
        return myEntity
    }
}
