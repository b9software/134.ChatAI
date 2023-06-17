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
        case fake = "<Fake>"

        var displayString: String {
            rawValue
        }
    }

    private(set) var entity: CDEngine
    let id: StringID
    let type: EType
    var name: String?

    private init(entity: CDEngine) throws {
        guard let type = EType(rawValue: entity.type ?? "") else {
            throw AppError.message("Engine> init with invalid type: \(entity.type ?? "nil").")
        }
        self.id = entity.id ?? "?"
        self.type = type
        self.name = entity.name
        self.entity = entity
        switch type {
        case .openAI:
            oaEngine = try entity.loadOAEngine()
        case .openAIProxy:
            oaEngine = try entity.loadOAEngine()
        case .fake:
            break
        }
    }

    private init(type: EType, oaEngine: OAEngine, entity: CDEngine) {
        self.id = entity.id ?? "?"
        self.type = type
        self.name = entity.name
        self.entity = entity
        self.oaEngine = oaEngine
    }

    static func from(entity: CDEngine) -> Engine? {
        assertDispatch(.notOnQueue(.main))
        guard let id = entity.id else {
            assertionFailure("CDEngine no id")
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

    static func instanceOf(id: String) -> Engine? {
        enginePool[id]
    }

    static func create(engine: OAEngine, logHandler log: LogHandler?, completion: @escaping (Result<Engine, Error>) -> Void) -> Task<Void, Never> {
        typealias L10 = L.Engine.Create
        let cb = Do.safe(callback: completion)
        return Task(priority: .utility) {
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
                let item = try await makeOpenAIItem(key: key, models: models)
                log?.x(.notice, L10.stepDone)
                cb(.success(item))
            } catch {
                log?.x(.error, error.localizedDescription)
                cb(.failure(error))
            }
        }
    }

    private static func makeOpenAIItem(key: String, models: [OAModel]) async throws -> Engine {
        guard let keyHash = B9Crypto.sha1(utf8: "OA-\(key)") else {
            throw AppError.message(L.Engine.Create.Fail.hashKey)
        }
        let id = "OA-" + keyHash
        if await CDEngine.fetch(id: id) != nil {
            throw AppError.message(L.Engine.Create.Fail.existKey)
        }
        try Current.keychain.update(string: key, account: id, label: "B9ChatAI Safe Store", comment: "Your OpenAI API key")
        let oaEngine = OAEngine(models: models)
        oaEngine.apiKey = key
        let oaData = try oaEngine.encode()
        let item = await Current.database.read {
            let entity = CDEngine(context: $0)
            entity.id = id
            entity.name = key.keyMasked().replacingOccurrences(of: "**", with: "*")
            entity.type = EType.openAI.rawValue
            entity.createTime = .current
            entity.usedTime = nil
            entity.raw = oaData
            $0.trySave()
            return Engine(type: .openAI, oaEngine: oaEngine, entity: entity)
        }
        return item
    }

    static func createProxy(engine: OAEngine, logHandler log: LogHandler?, completion: @escaping (Result<Engine, Error>) -> Void) -> Task<Void, Never> {
        typealias L10 = L.Engine.Create
        let cb = Do.safe(callback: completion)
        return Task(priority: .utility) {
            func failure(msg: String) {
                log?.x(.error, msg)
                cb(.failure(AppError.message(msg)))
            }
            do {
                guard let baseURL = engine.baseURL else {
                    failure(msg: "Base URL not set.")
                    return
                }
                let api = OANetwork(proxy: baseURL, apiKey: engine.apiKey)
                api.customCompletionURL = engine.customCompletionURL
                api.customListModelURL = engine.customListModelURL
                log?.x(.info, "POST \(api.completionURL.absoluteString)...")
                let talk = try await api.verifyChat()
                if talk.choices?.first?.message?.content == nil {
                    log?.x(.warning, L10.unrecognizedChatWarning)
                }

                log?.x(.info, "GET \(api.modelsURL.absoluteString)...")
                let models = try await api.listModel()
                let gptIds = models.map { $0.root ?? $0.id }.filter { $0.hasPrefix("gpt-") }.uniqued().sorted()
                let idDesc = gptIds.joined(separator: ", ")
                log?.x(.info, L10.stepListGpt(idDesc))

                log?.x(.info, L10.stepSaveData)
                let item = try await makeItem(proxy: engine, models: models)
                log?.x(.notice, L10.stepDone)
                cb(.success(item))
            } catch {
                log?.x(.error, error.localizedDescription)
                cb(.failure(error))
            }
        }
    }

    private static func makeItem(proxy: OAEngine, models: [OAModel]) async throws -> Engine {
        guard let host = proxy.baseURL?.host,
              let keyHash = B9Crypto.sha1(utf8: "OP-\(host)-\(proxy.apiKey ?? "")") else {
            throw AppError.message(L.Engine.Create.Fail.hashKey)
        }
        let id = "OP-" + keyHash
        if await CDEngine.fetch(id: id) != nil {
            throw AppError.message(L.Engine.Create.Fail.existProxy)
        }
        if let key = proxy.apiKey {
            try Current.keychain.update(string: key, account: id, label: "B9ChatAI Safe Store", comment: "Your OpenAI API key")
        }

        let oaData = try proxy.encode()
        let item = await Current.database.read {
            let entity = CDEngine(context: $0)
            entity.id = id
            entity.name = host
            entity.type = EType.openAIProxy.rawValue
            entity.createTime = .current
            entity.usedTime = nil
            entity.raw = oaData
            $0.trySave()
            return Engine(type: .openAIProxy, oaEngine: proxy, entity: entity)
        }
        return item
    }

    private(set) var oaEngine: OAEngine!
    private var _oaNetwork: OANetwork?
}

extension Engine {
    var isValid: Bool {
        switch type {
        case .openAI:
            return oaEngine.apiKey?.isNotEmpty == true
        case .openAIProxy:
            return oaEngine.baseURL != nil
        case .fake:
            return true
        }
    }

    var hasModels: Bool {
        switch type {
        case .openAI, .openAIProxy:
            return true
        default:
            return false
        }
    }

    private func getOANetworking() throws -> OANetwork {
        if let result = _oaNetwork { return result }
        switch type {
        case .openAI:
            guard let key = oaEngine.apiKey else {
                throw AppError.message("Engine is missing API key.")
            }
            let result = OANetwork(apiKey: key)
            _oaNetwork = result
            return result
        case .openAIProxy:
            guard let base = oaEngine.baseURL else {
                throw AppError.message("Engine is missing proxy URL.")
            }
            let result = OANetwork(proxy: base, apiKey: oaEngine.apiKey)
            result.customCompletionURL = oaEngine.customCompletionURL
            result.customListModelURL = oaEngine.customListModelURL
            _oaNetwork = result
            return result
        case .fake:
            fatalError("Fake engine no networking.")
        }
    }

    var lastSelectedModel: StringID? {
        get { oaEngine?.modelLastUsed }
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
            if Date.isRecent(oaEngine.modelLastFetchTime, range: 60) {
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

    func send(message: Message, config: EngineConfig) throws -> Task<Void, Error> {
        switch type {
        case .openAI, .openAIProxy:
            let api = try getOANetworking()
            return api.steamChat(config: config, steam: message.senderState?.noSteam != true, handler: message)
        case .fake:
            #if DEBUG
            return Self.genaralFakeResponse(message: message)
            #else
            throw AppError.message("Fake engine only available in debug build.")
            #endif
        }
    }
}

extension Engine: Hashable {
    static func == (lhs: Engine, rhs: Engine) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

#if DEBUG
extension Engine {
    static func createFakeOne() {
        Current.database.save {
            let entity = CDEngine(context: $0)
            entity.id = "fake"
            entity.name = "Fake"
            entity.type = EType.fake.rawValue
            entity.createTime = .current
            entity.usedTime = nil
            $0.trySave()
        }
    }

    static func genaralFakeResponse(message: Message) -> Task<Void, Error> {
        Task {
            var choice = OAChatCompletion.Choice(delta: OAChatMessage(role: .assistant))
            message.onSteamResponse(choice)
            for _ in 0...100 {
                choice = OAChatCompletion.Choice(delta: OAChatMessage(content: "."))
                message.onSteamResponse(choice)
                try await Task.sleep(nanoseconds: 50_000_000) // 50ms
            }
            choice = OAChatCompletion.Choice(delta: OAChatMessage(content: "@"), finishReason: "stop")
            message.onSteamResponse(choice)
        }
    }
}
#endif
