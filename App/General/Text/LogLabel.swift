//
//  LogLabel.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import Logging
import UIKit

class LogLabel: UILabel, LogHandler {

    func clear() {
        text = nil
        textColor = Asset.Text.thrid.color
    }

    func colorOf(level: Logger.Level) -> UIColor {
        switch level {
        case .error: return .systemRed
        case .warning: return .systemOrange
        case .notice: return .systemGreen
        default:
            return Asset.Text.thrid.color
        }
    }

    // swiftlint:disable:next function_parameter_count
    func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, source: String, file: String, function: String, line: UInt) {
        dispatch_sync_on_main { [self] in
            let aString = NSMutableAttributedString(attributedString: attributedText ?? NSAttributedString(""))
            aString.append(
                NSAttributedString(
                    string: "\n\(message)",
                    attributes: [.foregroundColor: colorOf(level: level)]
                )
            )
            attributedText = aString
        }
    }

    subscript(metadataKey key: String) -> Logging.Logger.Metadata.Value? {
        get { metadata[key] }
        set(newValue) { metadata[key] = newValue }
    }

    var metadata: Logging.Logger.Metadata = [:]

    var logLevel: Logging.Logger.Level = .info
}
