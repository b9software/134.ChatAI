//
//  AppIntents.swift
//  B9ChatAI
//
//  Created by BB9z on 2023/5/10.
//  Copyright © 2023 B9Software. All rights reserved.
//

import AppIntents

@available(macCatalyst 16.0, iOS 16.0, *)
struct ShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: TextIntent(), phrases: [
            "Send text to \(.applicationName)",
            "Proccess text with \(.applicationName)",
        ])
    }
}

@available(macCatalyst 16.0, iOS 16.0, *)
struct TextIntent: AppIntent {
    static var title = LocalizedStringResource("sendIntent.title", defaultValue: "Send Text to AI")

    static var description = IntentDescription(
        LocalizedStringResource("sendIntent.desc", defaultValue: "Send text to speifiy conversation. Returns the AI response after a while."),
        categoryName: LocalizedStringResource("sendIntent.category", defaultValue: "Chat"),
        searchKeywords: L.SendIntent.searchKeyword.split(separator: ",").map { LocalizedStringResource(stringLiteral: String($0)) }
    )

    @Parameter(
        title: LocalizedStringResource("sendIntent.conversationTitle", defaultValue: "Conversation"),
        description: LocalizedStringResource("sendIntent.conversationDesc", defaultValue: "Which conversation the text send to.")
    )
    var conversation: ITConversation

    @Parameter(
        title: LocalizedStringResource("sendIntent.textTitle", defaultValue: "Text"),
        description: LocalizedStringResource("sendIntent.textDesc", defaultValue: "The content send to the conversation."),
        inputOptions: .init(
            multiline: true
        ),
        requestValueDialog: IntentDialog(stringLiteral: L.SendIntent.textRequest)
    )
    var text: String

    static var parameterSummary: some ParameterSummary {
        Summary("Send \(\.$text) to \(\.$conversation)")
    }

    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        guard let content = text.trimmed() else {
            throw $text.needsValueError(IntentDialog(stringLiteral: L.SendIntent.textRequest))
        }
        guard let chat = await Conversation.load(id: conversation.id) else {
            throw $conversation.needsValueError(IntentDialog(stringLiteral: L.SendIntent.conversationInvalid))
        }
        let msg = try await Current.conversationManager.waitSend(text: content, to: chat)
        return .result(value: msg.cachedText ?? "❓")
    }
}
