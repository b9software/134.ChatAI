//
//  OANetwork.swift
//  B9ChatAI
//
//  Created by Joseph Zhao on 2023/4/1.
//  Copyright © 2023 B9Software. All rights reserved.
//

import Foundation

class OANetwork {
    var baseURL: URL = "https://api.openai.com/"
    let session: URLSession
    var acceptableContentTypes = ["application/json", "text/json"]
    var customCompletionURL: URL?
    var customListModelURL: URL?

    init(apiKey: String) {
        let config = URLSessionConfiguration.default
        config.allowsExpensiveNetworkAccess = true
        config.httpCookieAcceptPolicy = .always
        config.httpAdditionalHeaders = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json",
            "User-Agent": Current.userAgent,
        ]
        session = URLSession(configuration: config, delegate: nil, delegateQueue: nil)
    }

    init(proxy: URL, apiKey: String?) {
        let config = URLSessionConfiguration.default
        config.allowsExpensiveNetworkAccess = true
        config.httpCookieAcceptPolicy = .always
        var headers = [
            "Content-Type": "application/json",
            "User-Agent": Current.userAgent,
        ]
        if let apiKey = apiKey {
            headers["Authorization"] = "Bearer \(apiKey)"
        }
        config.httpAdditionalHeaders = headers
        baseURL = proxy
        session = URLSession(configuration: config, delegate: nil, delegateQueue: nil)
    }

    func request(path: String) throws -> URLRequest {
        guard let url = URL(string: path, relativeTo: baseURL) else {
            throw AppError.message("Internal error: unable create url of path: \(path).")
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        return request
    }

    var completionURL: URL {
        customCompletionURL
        ?? URL(string: "/v1/chat/completions", relativeTo: baseURL)!
    }
    var modelsURL: URL {
        customListModelURL
        ?? URL(string: "/v1/models", relativeTo: baseURL)!
    }

    func verifyChat() async throws -> OAChatCompletion {
        var request = URLRequest(url: completionURL)
        request.httpMethod = "POST"
        request.timeoutInterval = 20
        let body = #"{"model":"gpt-3.5-turbo","max_tokens":2,"messages":[{"role":"user","content":"hi"}]}"#
        request.httpBody = body.data(using: .utf8)

        AppLog().debug("Sending HTTP request: \(request.url!)")
        var (data, response) = try await session.data(for: request)
        data = try handleResponse(data: data, response: response)
        let talk = try OAChatCompletion.decode(data)
        return talk
    }

    func listModel() async throws -> [OAModel] {
        let request = URLRequest(url: modelsURL)
        AppLog().debug("Sending HTTP request: \(request.url!)")
        var (data, response) = try await session.data(for: request)
        data = try handleResponse(data: data, response: response)
        return try [OAModel].decode(data)
    }

    func steamChat(config: EngineConfig, steam: Bool, handler: Message) -> Task<Void, Error> {
        Task {
            var param = try config.toOpenAIParameters()
            var pMsg: [OAChatMessage] = try await handler.entity.buildContext()
            if let system = config.system {
                pMsg.insert(.init(role: .system, content: system), at: 0)
            }
            param["messages"] = pMsg.map { ["role": $0.role?.rawValue, "content": $0.content] }
            param["user"] = Current.identifierForVendor
            if steam {
                param["stream"] = true
            }

            var request = URLRequest(url: completionURL)
            request.httpMethod = "POST"
            request.timeoutInterval = 90
            request.httpBody = try JSONSerialization.data(withJSONObject: param)

            AppLog().debug("Sending HTTP request: \(request.url!)")
            if !steam {
                var (data, response) = try await session.data(for: request)
                data = try handleResponse(data: data, response: response)
                let talk = try OAChatCompletion.decode(data)
                try handler.onResponse(oaEntity: talk)
                return
            }
            let (result, response) = try await session.bytes(for: request)
            try Task.checkCancellation()
            AppLog().debug("Got HTTP response")
            try await handleResponse(stream: result, response: response)
            try Task.checkCancellation()

            for try await line in result.lines {
                try Task.checkCancellation()
                let part = try decodeStream(line: line)
                guard let choices = part?.choices else { continue }
                for choice in choices {
                    handler.onSteamResponse(choice)
                    // TODO: fix multi choice end
                    if let reason = choice.finishReason {
                        AppLog().debug("Reply finished: \(reason).")
                        return
                    }
                }
            }
        }
    }

    private func decodeStream(line: String) throws -> OAChatCompletion? {
        AppLog().debug("OA> Stream line: \(line)")
        guard line.hasPrefix("data:") else { return nil }
        guard let data = line.dropFirst(5).data(using: .utf8) else {
            throw AppError.message("Bad stream data.")
        }
        return try OAChatCompletion.decode(data)
    }
}

// MARK: - Response

extension OANetwork {
    func handleResponse(stream: URLSession.AsyncBytes, response: URLResponse) async throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            return
        }
        let statusCode = httpResponse.statusCode
        guard 200..<300 ~= statusCode else {
            var body = ""
            for try await line in stream.lines {
                body += line
            }
            let data = body.data(using: .utf8, allowLossyConversion: true)
            if let error = tryDecodeErrorStruct(from: data) {
                throw error
            }
            let description = HTTPURLResponse.localizedString(forStatusCode: statusCode)
            throw AppError.message("HTTP \(statusCode): \(description).")
        }
    }

    func handleResponse(data: Data?, response: URLResponse) throws -> Data {
        if let httpResponse = response as? HTTPURLResponse {
            // 检查 HTTP 状态码
            let statusCode = httpResponse.statusCode
            guard 200..<300 ~= statusCode else {
                if let error = tryDecodeErrorStruct(from: data) {
                    throw error
                }
                let description = HTTPURLResponse.localizedString(forStatusCode: statusCode)
                throw AppError.message("HTTP \(statusCode): \(description).")
            }

            // 检查 Content-Type
            if let rspType = httpResponse.mimeType {
                guard acceptableContentTypes.contains(rspType) else {
                    throw AppError.message("HTTP invalid content type: \(rspType).")
                }
            }
        } // END: as HTTPURLResponse

        // 数据非空
        guard let data = data, !data.isEmpty else {
            throw AppError.message("Empty response.")
        }

        // 尝试 JSON 解析
        do {
            let object = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
            if let dict = object as? [String: Any],
                let obj = dict["data"] {
                // swiftlint:disable:next force_try
                return try! JSONSerialization.data(withJSONObject: obj)
            }
        } catch {
            throw AppError.message("Invalid JSON response: \(error.localizedDescription).")
        }

        return data
    }

    private func tryDecodeErrorStruct(from data: Data?) -> OAError? {
        guard let data = data, !data.isEmpty else {
            return nil
        }
        if let result = try? OAError.decode(data),
           result.error != nil {
            return result
        }
        // 尝试解析第三方接口
        guard let info = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            if let context = String(data: data, encoding: .utf8) {
                return OAError.badContext(context)
            }
            return OAError.badString()
        }
        var message: String?
        var code: String?
        var type: String?
        if let messageField = info["message"] ?? info["msg"] {
            message = "\(messageField)"
        }
        if let codeField = info["code"] {
            code = "\(codeField)"
        }
        if let typeField = info["type"] {
            type = "\(typeField)"
        }
        return OAError(error: OAErrorDetail(message: message, type: type, code: code))
    }
}
