//
//  CDDefines+.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import CoreData

// swiftlint:disable extension_access_modifier missing_docs identifier_name

@objc(CDEngine)
public class CDEngine: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDEngine> {
        return NSFetchRequest<CDEngine>(entityName: "Engine")
    }

    @NSManaged public var createTime: Date?
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var raw: Data?
    @NSManaged public var type: String?
    @NSManaged public var usedTime: Date?
    @NSManaged public var conversation: NSSet?
}

extension CDEngine {
    @objc(addConversationObject:)
    @NSManaged public func addToConversation(_ value: CDConversation)

    @objc(removeConversationObject:)
    @NSManaged public func removeFromConversation(_ value: CDConversation)

    @objc(addConversation:)
    @NSManaged public func addToConversation(_ values: NSSet)

    @objc(removeConversation:)
    @NSManaged public func removeFromConversation(_ values: NSSet)
}

// MARK: -

@objc(CDConversation)
public class CDConversation: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDConversation> {
        return NSFetchRequest<CDConversation>(entityName: "Conversation")
    }

    @NSManaged public var archiveTime: Date?
    @NSManaged public var createTime: Date?
    @NSManaged public var cSetting: Data?
    @NSManaged public var deleteTime: Date?
    @NSManaged public var engine: CDEngine?
    @NSManaged public var eSetting: Data?
    @NSManaged public var id: String!
    @NSManaged public var isTop: Bool
    @NSManaged public var lastTime: Date?
    @NSManaged public var messages: NSSet?
    /// 每次查看更新
    @NSManaged public var readTime: Date?
    /// 热键调起
    @NSManaged public var shortCut: String?
    /// 排序辅助
    @NSManaged public var sort: Int32
    @NSManaged public var subType: String?
    @NSManaged public var title: String?
    @NSManaged public var type: String?
    /// 保存设置的时间，估计可以用于冲突解决
    @NSManaged public var updateTime: Date?
}

extension CDConversation {
    @objc(addMessagesObject:)
    @NSManaged public func addToMessages(_ value: CDMessage)

    @objc(removeMessagesObject:)
    @NSManaged public func removeFromMessages(_ value: CDMessage)

    @objc(addMessages:)
    @NSManaged public func addToMessages(_ values: NSSet)

    @objc(removeMessages:)
    @NSManaged public func removeFromMessages(_ values: NSSet)
}

// MARK: -

@objc(CDMessage)
public class CDMessage: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDMessage> {
        return NSFetchRequest<CDMessage>(entityName: "Message")
    }

    @NSManaged public var uid: UUID!
    /// 上下文创建时间，用于列表排序
    @NSManaged public var time: Date!
    @NSManaged public var by: String!

    /// 类型
    @NSManaged public var type: Int16
    /// 解析的消息体内容，需要结合 type 去解析
    @NSManaged public var content: Data?
    /// 媒体内容
    @NSManaged public var medias: Data?
    /// 返回收到的时间
    @NSManaged public var updateTime: Date?
    /// 缓存的文本内容，简单的文本消息直接存这
    @NSManaged public var text: String?
    /// 消息状态，暂定发送状态
    @NSManaged public var state: Int16
    /// 结束状态，区分是否还有下文
    @NSManaged public var end: Int16

    @NSManaged public var conversation: CDConversation?

    /// 上下文关联，双向链表；对于 parent，指向子的第一个
    @NSManaged public var prev: UUID?
    /// 上下文关联，双向链表；对于 parent，指向子的最后一个
    @NSManaged public var next: UUID?

    @NSManaged public var child: NSSet?
    @NSManaged public var parent: CDMessage?

    @objc(addChildObject:)
    @NSManaged public func addToChild(_ value: CDMessage)

    @objc(removeChildObject:)
    @NSManaged public func removeFromChild(_ value: CDMessage)

    @objc(addChild:)
    @NSManaged public func addToChild(_ values: NSSet)

    @objc(removeChild:)
    @NSManaged public func removeFromChild(_ values: NSSet)
}
