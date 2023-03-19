// The MIT License (MIT)
//
// Copyright (c) 2020–2022 Alexander Grebenyuk (github.com/kean).

import Foundation
import SwiftUI
import Pulse

#if os(iOS) || os(macOS)

#if DEBUG

struct DecodingErrors_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            fileViewer(error: typeMismatchError())
                .previewDisplayName("Type Mismatch (Object)")
            fileViewer(error: typeMismatchErrorInArray())
                .previewDisplayName("Type Mismatch (Array)")
            fileViewer(error: valueNotFoundError())
                .previewDisplayName("Value Not Found")
            fileViewer(error: keyNotFound())
                .previewDisplayName("Key Not Found")
            fileViewer(error: dataCorrupted())
                .previewDisplayName("Data Corrupted")

        }
    }

    private static func fileViewer(error: NetworkLogger.DecodingError) -> some View {
        FileViewer(viewModel: .init(title: "Response", context: .init(contentType: .init(rawValue: "application/json"), originalSize: 1200, error: error), data: { MockJSON.allPossibleValues }))
    }
}

private func typeMismatchError() -> NetworkLogger.DecodingError {
    struct JSON: Decodable {
        let actors: [Actor]

        struct Actor: Decodable {
            let age: String
        }
    }
    return getError(JSON.self)
}

private func typeMismatchErrorInArray() -> NetworkLogger.DecodingError {
    struct JSON: Decodable {
        let actors: [Actor]

        struct Actor: Decodable {
            let children: [Int]
        }
    }
    return getError(JSON.self)
}

private func valueNotFoundError() -> NetworkLogger.DecodingError {
    struct JSON: Decodable {
        let actors: [Actor]

        struct Actor: Decodable {
            let wife: String
        }
    }
    return getError(JSON.self)
}

private func keyNotFound() -> NetworkLogger.DecodingError {
    struct JSON: Decodable {
        let actors: [Actor]

        struct Actor: Decodable {
            let lastName: String
        }
    }
    return getError(JSON.self)
}

private func dataCorrupted() -> NetworkLogger.DecodingError {
    struct JSON: Decodable {
        let actors: [Actor]

        struct Actor: Decodable {
            let name: URL
        }
    }
    return getError(JSON.self)
}

private func getError<T: Decodable>(_ type: T.Type) -> NetworkLogger.DecodingError {
    do {
        _ = try JSONDecoder().decode(type, from: MockJSON.allPossibleValues)
        fatalError()
    } catch {
        return NetworkLogger.DecodingError(error as! DecodingError)
    }
}

#endif

#endif
