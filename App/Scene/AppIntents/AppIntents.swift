//
//  AppIntents.swift
//  B9ChatAI
//
//  Created by BB9z on 2023/5/10.
//  Copyright © 2023 B9Software. All rights reserved.
//

import AppIntents

@available(macCatalyst 16.0, *)
struct ShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: TextIntent(), phrases: [
            "Send text to \(.applicationName)",
            "Proccess text with \(.applicationName)",
        ])
    }
}

@available(macCatalyst 16.0, *)
struct TextIntent: AppIntent {
    static var title: LocalizedStringResource = "Send text"

    static var description = IntentDescription(
"""
Send text to speifiy conversation.
""",
        categoryName: "Chat",
        searchKeywords: [
            "text",
            "ai",
            "chat",
        ]
    )

    @Parameter(
        title: "Conversation",
        description: "Which conversation the text send to."
    )
    var conversation: ITConversation

    @Parameter(
        title: "Text",
        description: "The content send to the conversation.",
        inputOptions: .init(
            multiline: true
        ),
        requestValueDialog: IntentDialog("Input some text")
    )
    var text: String

    static var parameterSummary: some ParameterSummary {
        Summary("Send \(\.$text) to \(\.$conversation)")
    }

    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        guard let content = text.trimmed() else {
            throw $text.needsValueError("Input is empty. Input some new text:")
        }
        guard let chat = await Conversation.load(id: conversation.id) else {
            throw $conversation.needsValueError("Choosed conversation is invaild.")
        }
        let msg = try await Current.conversationManager.waitSend(text: content, to: chat)
        return .result(value: msg.cachedText ?? "❓")
    }
}
