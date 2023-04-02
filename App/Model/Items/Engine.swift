//
//  Engine.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import CoreData
import Logging

private let enginePool = ObjectPool<StringID, Engine>()

class Engine {
    enum EType: String {
        case openAI = "OpenAI"
        case openAIProxy = "OpenAI Proxy"

        var displayString: String {
            rawValue
        }
    }

    var entity: CDEngine
    let type: EType
    var oaEngine: OAEngine {
        didSet {
            Do.try {
                entity.raw = try oaEngine.encode()
            }
        }
    }

    private init(entity: CDEngine) throws {
        guard let type = EType(rawValue: entity.type ?? "") else {
            throw AppError.message("Engine> init with invalid type: \(entity.type ?? "nil").")
        }
        self.type = type
        self.entity = entity
        switch type {
        case .openAI:
            guard let raw = entity.raw else {
                throw AppError.message("Engine> init with nil raw.")
            }
            oaEngine = try OAEngine.decode(raw)
            if let id = entity.id {
                oaEngine.apiKey = try B9Keychain.string(account: id)
            }
        case .openAIProxy:
            fatalError("todo")
        }
    }

    private init(type: EType, oaEngine: OAEngine, entity: CDEngine) {
        self.type = type
        self.oaEngine = oaEngine
        self.entity = entity
    }

    static func from(entity: CDEngine) -> Engine? {
        entity.access { _ in
            guard let id = entity.id else {
                assert(false)
                return nil
            }
            if let old = enginePool[id] { return old }
            do {
                let new = try Engine(entity: entity)
                enginePool[id] = new
                return new
            } catch {
                AppLog().critical("Unable load engine from db: \(error).")
                return nil
            }
        }
    }

    static func create(engine: OAEngine, logHandler log: LogHandler?, completion: @escaping (Result<Engine, Error>) -> Void) -> Task<Void, Never> {
        typealias L10 = L.Engine.Create
        let cb = Do.safe(callback: completion)
        return Task(priority: .utility) {
            assertDispatch(.notOnQueue(.main))
            func failure(msg: String) {
                log?.x(.error, msg)
                cb(.failure(AppError.message(msg)))
            }
            do {
                guard let key = engine.apiKey else {
                    failure(msg: "API not set.")
                    return
                }
                let api = OANetwork(apiKey: key)
                log?.x(.info, L10.stepVerify)
                let talk = try await api.verifyChat()
                if talk.choices?.first?.message?.content == nil {
                    log?.x(.warning, L10.unrecognizedChatWarning)
                }
                log?.x(.info, L10.stepModels)
                let models = try await api.listModel()
                let gptIds = models.map { $0.root ?? $0.id }.filter { $0.hasPrefix("gpt-") }.uniqued().sorted()
                let idDesc = gptIds.joined(separator: ", ")
                log?.x(.info, L10.stepListGpt(idDesc))

                log?.x(.info, L10.stepSaveData)
                let item = try await makeItem(key: key, models: models)
                log?.x(.notice, L10.stepDone)
                cb(.success(item))
            } catch {
                log?.x(.error, error.localizedDescription)
                cb(.failure(error))
            }
        }
    }

    private static func makeItem(key: String, models: [OAModel]) async throws -> Engine {
        guard let keyHash = B9Crypto.sha1(utf8: "OA-\(key)") else {
            throw AppError.message(L.Engine.Create.Fail.hashKey)
        }
        let id = "OA-" + keyHash
        if CDEngine.fetch(id: id) != nil {
            throw AppError.message(L.Engine.Create.Fail.existKey)
        }
        try B9Keychain.update(string: key, account: id, label: "B9ChatAI Safe Store", comment: "Your OpenAI API key")
        let oaEngine = OAEngine(models: models)
        oaEngine.apiKey = key
        let oaData = try oaEngine.encode()
        let item = Current.database.context.perform {
            let entity = CDEngine(context: $0)
            entity.id = id
            entity.name = key.keyMasked()
            entity.type = EType.openAI.rawValue
            entity.createTime = .current
            entity.usedTime = nil
            entity.raw = oaData
            return Engine(type: .openAI, oaEngine: oaEngine, entity: entity)
        }
        return item
    }
}

extension Engine {
    var isValid: Bool {
        switch type {
        case .openAI:
            return oaEngine.apiKey?.isNotEmpty == true
        case .openAIProxy:
            return false
        }
    }
}
