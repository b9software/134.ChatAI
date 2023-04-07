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
        time = .current
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
        if by == nil {
            AppLog().critical("CD> Missing by: \(self).")
        }
        if state == 0 {
            AppLog().critical("CD> Bad state: \(self).")
        }
        #endif
    }
}

extension CDMessage {
    static let timeKey = #keyPath(CDMessage.time)
    static let stateKey = #keyPath(CDMessage.state)

    static func createMy(_ ctx: NSManagedObjectContext, text: String) -> CDMessage {
        let entity = CDMessage(context: ctx)
        entity.type = Message.MType.text.rawValue
        entity.mRole = .me
        entity.mState = .normal
        entity.text = text
        return entity
    }

    /// 消息列表
    static func conversationRequest(_ chatEntity: CDConversation, offset: Int, limit: Int, ascending: Bool) -> NSFetchRequest<CDMessage> {
        let request = fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: timeKey, ascending: false),
        ]
        request.fetchOffset = offset
        request.fetchLimit = limit
        request.predicate = NSPredicate(format: "conversation == %@", chatEntity)
        return request
    }

    /// 待发送消息
    static func pendingRequest() -> NSFetchRequest<CDMessage> {
        let request = fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: timeKey, ascending: false),
        ]
        request.predicate = NSPredicate(format: "%K == %d", stateKey, Message.MState.pend.rawValue)
        return request
    }
}

extension CDMessage: ModelValidate {
    /// 空是不识别，不应显示
    var mType: Message.MType {
        .init(rawValue: type) ?? .bad
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

    func validate() throws {
        if mType == .bad {
            throw AppError.message("Bad type")
        }
        if mState == .bad {
            throw AppError.message("Bad state")
        }
    }
}
