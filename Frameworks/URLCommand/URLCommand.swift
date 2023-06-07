//
//  URLCommand.swift
//  B9ChatAI
//
//  Created by BB9z on 2023/6/8.
//  Copyright © 2023 B9Software. All rights reserved.
//

import Foundation

enum URLCommand {
    static var scheme: String {
        Bundle.main.bundleIdentifier ?? "b9chatai"
    }

    static func generateJSBookmark(id: String) -> String {
        let urlPart = generateSendURL(id: id, text: "").url?.absoluteString ?? ""
        return "javascript:a=\"\(urlPart)\"+encodeURIComponent(window.getSelection().toString());window.location.href=a"
    }

    static func generateRaycastSwitch(id: String) -> String {
        generateSendURL(id: id, text: nil).url?.absoluteString ?? ""
    }

    static func generateRaycastQuery(id: String, paramText: String) -> String {
        let urlPart = generateSendURL(id: id, text: "").url?.absoluteString ?? ""
        return "\(urlPart){\(paramText)}"
    }

    static func generateSendURL(id: String, text: String?) -> URLComponents {
        var comp = URLComponents()
        comp.scheme = scheme
        comp.host = "send"
        comp.queryItems = [
            .init(name: "id", value: id),
        ]
        if let text = text {
            comp.queryItems?.append(.init(name: "text", value: text))
        }
        return comp
    }
}
