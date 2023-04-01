// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum InfoPlist {
    }
  internal enum Localizable {
    internal enum Engine {
      internal enum Create {
        /// [OK]
        internal static let stepDone = L10n.tr("Localizable", "engine.create.step-done", fallback: "[OK]")
        /// Available GPT models: %@
        internal static func stepListGpt(_ p1: Any) -> String {
          return L10n.tr("Localizable", "engine.create.step-list-gpt", String(describing: p1), fallback: "Available GPT models: %@")
        }
        /// Checking models...
        internal static let stepModels = L10n.tr("Localizable", "engine.create.step-models", fallback: "Checking models...")
        /// Save data.
        internal static let stepSaveData = L10n.tr("Localizable", "engine.create.step-save-data", fallback: "Save data.")
        /// Verifying....
        internal static let stepVerify = L10n.tr("Localizable", "engine.create.step-verify", fallback: "Verifying....")
        /// It seems that the chat content is not read properly, please check if there is a new version of B9ChatAI.
        internal static let unrecognizedChatWarning = L10n.tr("Localizable", "engine.create.unrecognized-chat-warning", fallback: "It seems that the chat content is not read properly, please check if there is a new version of B9ChatAI.")
        internal enum Fail {
          /// Engine with the given key already exist.
          internal static let existKey = L10n.tr("Localizable", "engine.create.fail.exist-key", fallback: "Engine with the given key already exist.")
          /// Unable to generate secure data for key.
          internal static let hashKey = L10n.tr("Localizable", "engine.create.fail.hash-key", fallback: "Unable to generate secure data for key.")
        }
      }
    }
    internal enum Menu {
      /// Delete
      internal static let delete = L10n.tr("Localizable", "menu.delete", fallback: "Delete")
      /// New
      internal static let new = L10n.tr("Localizable", "menu.new", fallback: "New")
      internal enum New {
        /// Conversation
        internal static let conversation = L10n.tr("Localizable", "menu.new.conversation", fallback: "Conversation")
        /// Window Tab
        internal static let tab = L10n.tr("Localizable", "menu.new.tab", fallback: "Window Tab")
        /// Window
        internal static let window = L10n.tr("Localizable", "menu.new.window", fallback: "Window")
      }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = Bundle.main.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}
