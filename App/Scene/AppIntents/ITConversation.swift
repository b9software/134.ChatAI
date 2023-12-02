//
//  ITConversation.swift
//  B9ChatAI
//
//  Created by BB9z on 2023/5/10.
//  Copyright © 2023 B9Software. All rights reserved.
//

import AppIntents

@available(macCatalyst 16.0, iOS 16.0, *)
struct ITConversation: AppEntity, Identifiable {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Conversation"

    var id: StringID

    @Property(title: "Title")
    var title: String

    var displayRepresentation: DisplayRepresentation { DisplayRepresentation(title: LocalizedStringResource(stringLiteral: title)) }

    static var defaultQuery = ITConversationQuery()

    init(entity: CDConversation) {
        id = entity.id
        title = entity.title ?? L.Chat.defaultTitle
    }
}

@available(macCatalyst 16.0, iOS 16.0, *)
// 添加 EntityStringQuery 支持
struct ITConversationQuery: EntityQuery {
    func entities(for identifiers: [StringID]) async throws -> [ITConversation] {
        try await Current.database.read { ctx in
            try identifiers
                .compactMap {
                    try ctx.fetch(CDConversation.request(id: $0)).first
                }
                .map(ITConversation.init(entity:))
        }
    }

    func suggestedEntities() async throws -> [ITConversation] {
        try await Current.database.read { ctx in
            try ctx.fetch(CDConversation.chatListRequest)
                .map(ITConversation.init(entity:))
        }
    }
}
