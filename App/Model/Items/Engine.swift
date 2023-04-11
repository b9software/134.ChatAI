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

    private(set) var entity: CDEngine
    let type: EType

    private init(entity: CDEngine) throws {
        guard let type = EType(rawValue: entity.type ?? "") else {
            throw AppError.message("Engine> init with invalid type: \(entity.type ?? "nil").")
        }
        self.type = type
        self.entity = entity
        switch type {
        case .openAI:
            oaEngine = try entity.loadOAEngine()
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
                AppLog().debug("Engine> Create instance of \(id).")
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
        if await CDEngine.fetch(id: id) != nil {
            throw AppError.message(L.Engine.Create.Fail.existKey)
        }
        try B9Keychain.update(string: key, account: id, label: "B9ChatAI Safe Store", comment: "Your OpenAI API key")
        let oaEngine = OAEngine(models: models)
        oaEngine.apiKey = key
        let oaData = try oaEngine.encode()
        let item = await Current.database.write {
            let entity = CDEngine(context: $0)
            entity.id = id
            entity.name = key.keyMasked().replacingOccurrences(of: "**", with: "*")
            entity.type = EType.openAI.rawValue
            entity.createTime = .current
            entity.usedTime = nil
            entity.raw = oaData
            return Engine(type: .openAI, oaEngine: oaEngine, entity: entity)
        }
        return item
    }

    private var oaEngine: OAEngine
    private var _oaNetwork: OANetwork?
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

    private func getOANetworking() throws -> OANetwork {
        if let result = _oaNetwork { return result }
        guard let key = oaEngine.apiKey else {
            throw AppError.message("Engine is missing API key.")
        }
        let result = OANetwork(apiKey: key)
        _oaNetwork = result
        return result
    }

    var lastSelectedModel: StringID? {
        get { oaEngine.modelLastUsed }
        set {
            if oaEngine.modelLastUsed == newValue { return }
            oaEngine.modelLastUsed = newValue
            entity.save(oaEngine: oaEngine)
        }
    }

    func listModel() -> [StringID]? {
        guard let models = oaEngine.models else {
            return nil
        }
        return models.filter { $0.isChatMode }.map { $0.id }
    }

    func refreshModels() -> Task<[StringID], Error> {
        Task {
            if Date.isRecent(oaEngine.modelLastFetchTime, range: 20) {
                return listModel() ?? []
            }
            let api = try getOANetworking()
            AppLog().info("Engine> Start refresh models...")
            oaEngine.models = try await api.listModel()
            oaEngine.modelLastFetchTime = .current
            entity.save(oaEngine: oaEngine)
            return listModel() ?? []
        }
    }

    func updateUsedTime() {
        entity.modify { this, _ in
            this.usedTime = .current
        }
    }

    func send(message: Message, config: EngineConfig) -> Task<Void, Error> {
        Task {
            if type != .openAI {
                throw AppError.message("Only OpenAI API is supported.")
            }
            let api = try getOANetworking()
            let stream = try await api.steamChat(config: config, messages: [
                .init(role: .user, content: "test")
            ])
            if Task.isCancelled { return }

            for try await choice in stream {
                if Task.isCancelled { return }
                message.onSteamResponse(choice)
            }
            AppLog().debug("Stream Receive end")
        }
    }
}
