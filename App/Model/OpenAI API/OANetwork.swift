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

    init(apiKey: String) {
        let config = URLSessionConfiguration.default
        config.allowsExpensiveNetworkAccess = true
        config.httpCookieAcceptPolicy = .always
        config.httpAdditionalHeaders = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json; charset=utf-8",
        ]
        session = URLSession(configuration: config, delegate: nil, delegateQueue: nil)
    }

    class Request<Success> {
        var result: Result<Success, Error>? {
            didSet {
                if let result = result, let cb = completion {
                    cb(result)
                    completion = nil
                }
            }
        }
        var task: URLSessionTask?
        var completion: ((Result<Success, Error>) -> Void)?
        var request: URLRequest?
        var response: URLResponse?

        func cancel() {
            if let task = task {
                task.cancel()
                self.task = nil
            }
            if result == nil {
                result = .failure(AppError.cancel)
            }
        }
    }

    func request(path: String) throws -> URLRequest {
        guard let url = URL(string: path, relativeTo: baseURL) else {
            throw AppError.message("Internal error: unable create url of path: \(path).")
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        return request
    }

    func verifyChat() async throws -> OAChatCompletion {
        var request = URLRequest(url: URL(string: "/v1/chat/completions", relativeTo: baseURL)!)
        request.httpMethod = "POST"
        request.timeoutInterval = 20
        let body = #"{"model":"gpt-3.5-turbo","max_tokens":2,"messages":[{"role":"user","content":"hi"}]}"#
        request.httpBody = body.data(using: .utf8)

        var (data, response) = try await session.data(for: request)
        data = try handleResponse(data: data, response: response, error: nil)
        let talk = try OAChatCompletion.decode(data)
        return talk
    }

    func listModel() async throws -> [OAModel] {
        let request = URLRequest(url: URL(string: "/v1/models", relativeTo: baseURL)!)
        var (data, response) = try await session.data(for: request)
        data = try handleResponse(data: data, response: response, error: nil)
        return try [OAModel].decode(data)
    }
}

// MARK: - Response

struct OAErrorDetail: Codable {
    var message: String?
    var type: String?
    var code: String?
}

struct OAError: Codable, LocalizedError {
    var error: OAErrorDetail?

    var errorDescription: String? {
        guard let info = error else {
            return "Unknown OpenAI error."
        }
        var msg = info.message ?? "Unknown OpenAI error."
        if let type = info.code ?? info.type {
            msg += " [\(type)]"
        }
        return msg
    }

    var isInvalidApiKey: Bool {
        error?.code == "invalid_api_key"
    }
}

extension OANetwork {
    func handleResponse(data: Data?, response: URLResponse?, error: Error?) throws -> Data {
        if let err = error { throw err }
        if let httpResponse = response as? HTTPURLResponse {
            // 检查 HTTP 状态码
            let statusCode = httpResponse.statusCode
            let isSuccessStatus = 200..<300 ~= statusCode
            guard isSuccessStatus else {
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
        return try? OAError.decode(data)
    }
}
