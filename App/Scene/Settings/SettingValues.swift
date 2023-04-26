//
//  SettingValues.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import Foundation

enum Sendby: Int, Equatable {
    // followApp = nil
    case command = 0
    case shift = 1
    case enter = 2

    init?(_ rawValue: Int?) {
        switch rawValue {
        case 0:
            self = .command
        case 1:
            self = .shift
        case 2:
            self = .enter
        default:
            return nil
        }
    }

    var symbolDescription: String {
        switch self {
        case .command: return "⌘⏎"
        case .shift: return "⇧⏎"
        case .enter: return "⏎"
        }
    }

    var keyDescription: String {
        switch self {
        case .command: return "Command+Enter"
        case .shift: return "Shift+Enter"
        case .enter: return "Enter"
        }
    }

    var keyModifierFlags: UIKeyModifierFlags {
        switch self {
        case .command: return [.command]
        case .shift: return [.shift]
        case .enter: return []
        }
    }
}
