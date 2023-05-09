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
    static let uidKey = #keyPath(CDMessage.uid)

    /// 消息列表
    static func conversationRequest(_ chatEntity: CDConversation, offset: Int, limit: Int, ascending: Bool) -> NSFetchRequest<CDMessage> {
        let request = fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: timeKey, ascending: false),
            NSSortDescriptor(key: createTimeKey, ascending: false),
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
        request.predicate = NSPredicate(
            format: "%K == %d AND %K == nil",
            stateKey, Message.MState.pend.rawValue,
            deleteTimeKey
        )
        return request
    }

    static func childRequest(parent: CDMessage) -> NSFetchRequest<CDMessage> {
        let request = fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: createTimeKey, ascending: true),
        ]
        request.predicate = NSPredicate(
            format: "%K == %@ AND %K == nil",
            parentKey, parent,
            deleteTimeKey
        )
        return request
    }

    static func entity(uuid: UUID?, context: NSManagedObjectContext) -> CDMessage? {
        guard let uuid = uuid else {
            return nil
        }
        let request = fetchRequest()
        request.predicate = NSPredicate(
            format: "%K == %@",
            uidKey, uuid as NSUUID
        )
        do {
            let entities = try context.fetch(request)
            assert(entities.count <= 1)
            return entities.first
        } catch {
            AppLog().critical("\(error)")
            return nil
        }
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
            debugPrint(messages.map { $0.text ?? "nil" })
            debugPrint(messages.map { $0.createTime?.localTime ?? "nil" })
            let result: [OAChatMessage] = messages.compactMap { entity in
                guard entity.deleteTime == nil else {
                    return nil
                }
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
    static func createEntities(_ ctx: NSManagedObjectContext, conversation: NSManagedObjectID, reply: NSManagedObjectID?) throws -> (CDMessage, CDMessage) {
        guard let safeChat = ctx.object(with: conversation) as? CDConversation else {
            throw AppError.message("Unable get conversation entity.")
        }
        let myEntity = CDMessage(context: ctx)
        myEntity.mRole = .me
        myEntity.mState = .normal
        myEntity.conversation = safeChat

        let replyEntity: CDMessage?
        if let replyID = reply {
            replyEntity = ctx.object(with: replyID) as? CDMessage
        } else {
            replyEntity = nil
        }
        let parentEntity: CDMessage = replyEntity?.parent ?? replyEntity ?? myEntity
        if myEntity != parentEntity {
            myEntity.parent = parentEntity
        }

        let newEntity = newTextEntity(parent: parentEntity, context: ctx)
        newEntity.conversation = safeChat

        myEntity.time = parentEntity.time
        parentEntity.updateTime = .current

        let isReplyParent = replyEntity == parentEntity
        var replyNextID = isReplyParent ? parentEntity.prev : replyEntity?.next
        while let id = replyNextID {
            let entity = entity(uuid: id, context: ctx)
            if let entity = entity {
                ctx.delete(entity)
                parentEntity.removeFromChild(entity)
                AppLog().warning("Delete context message: \(entity.text ?? entity.time.localTime)")
            }
            replyNextID = entity?.next
        }
        replyEntity?.next = myEntity.uid
        myEntity.prev = replyEntity?.uid ?? newEntity.uid
        myEntity.next = newEntity.uid
        newEntity.prev = myEntity.uid
        if isReplyParent {
            parentEntity.prev = myEntity.uid
        }
        parentEntity.next = newEntity.uid
        assertParent(parentEntity, ctx)
        return (myEntity, newEntity)
    }

    static func newTextEntity(parent: CDMessage, context: NSManagedObjectContext) -> CDMessage {
        let newEntity = CDMessage(context: context)
        newEntity.mType = .text
        newEntity.mRole = .assistant
        newEntity.mState = .pend
        newEntity.parent = parent
        #if DEBUG
        if AppDelegate().debug.debugMessageSkipSending {
            newEntity.mState = .normal
            newEntity.text = "Debug Skip \(Date.current.localTime)"
            newEntity.content = try? CDMessageContent().encode()
        }
        #endif

        newEntity.time = parent.time
        return newEntity
    }

    func appendContinue(context: NSManagedObjectContext) {
        guard let parentEntity = parent else {
            assert(false)
            return
        }
        let newEntity = Self.newTextEntity(parent: parentEntity, context: context)
        newEntity.conversation = conversation
        parentEntity.updateTime = .current

        if let oldNext = next {
            newEntity.next = oldNext
            let oldNextEntity = Self.entity(uuid: oldNext, context: context)
            oldNextEntity?.prev = newEntity.uid
        } else {
            parentEntity.next = newEntity.uid
        }
        newEntity.prev = uid
        next = newEntity.uid
        Self.assertParent(parentEntity, context)
    }

    #if DEBUG
    static func assertParent(_ parent: CDMessage, _ ctx: NSManagedObjectContext) {
        assert(parent.parent == nil)
        assert(parent.next != nil)
        assert(parent.prev != nil)
        let count = parent.child?.count ?? 0
        var uid = parent.prev
        var linkCount = 0
        while let entity = entity(uuid: uid, context: ctx) {
            uid = entity.next
            linkCount += 1
            assert(linkCount < 30)
        }
        assert(linkCount == count)
        uid = parent.next
        linkCount = 0
        while let entity = entity(uuid: uid, context: ctx) {
            if entity == parent { break }
            uid = entity.prev
            linkCount += 1
            assert(linkCount < 30)
        }
        assert(linkCount == count)
        parent.child?.forEach {
            // swiftlint:disable:next force_cast
            assert(($0 as! CDMessage).parent == parent)
        }
    }
    #else
    @inline(__always)
    static func assertParent(_ parentEntity: CDMessage, _ ctx: NSManagedObjectContext) {}
    #endif
}
