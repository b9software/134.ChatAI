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
    internal enum App {
      /// B9ChatAI does not collect any of your data, and all data is under your control.
      /// 
      /// However, when using the application, third-party services may be called upon, which may collect your information. While you have control over which services are called upon, it is still important for you to be vigilant about protecting your information, carefully read and understand the privacy policies of related services, and be especially cautious when using proxy servers provided by third parties.
      internal static let privacySort = L10n.tr("Localizable", "app.privacy-sort", fallback: "B9ChatAI does not collect any of your data, and all data is under your control.\n\nHowever, when using the application, third-party services may be called upon, which may collect your information. While you have control over which services are called upon, it is still important for you to be vigilant about protecting your information, carefully read and understand the privacy policies of related services, and be especially cautious when using proxy servers provided by third parties.")
    }
    internal enum Chat {
      /// Archived
      internal static let archived = L10n.tr("Localizable", "chat.archived", fallback: "Archived")
      /// New Chat
      internal static let defaultTitle = L10n.tr("Localizable", "chat.defaultTitle", fallback: "New Chat")
      /// Deleted
      internal static let deleted = L10n.tr("Localizable", "chat.deleted", fallback: "Deleted")
      /// Delete Immediately
      internal static let deleteNow = L10n.tr("Localizable", "chat.deleteNow", fallback: "Delete Immediately")
      /// Undelete
      internal static let deleteRestore = L10n.tr("Localizable", "chat.deleteRestore", fallback: "Undelete")
      /// You must set up the engine before you can chat.
      internal static let setupBeforeUseNotice = L10n.tr("Localizable", "chat.setupBeforeUseNotice", fallback: "You must set up the engine before you can chat.")
      /// Unarchive
      internal static let unArchive = L10n.tr("Localizable", "chat.unArchive", fallback: "Unarchive")
    }
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
      /// Archive
      internal static let archive = L10n.tr("Localizable", "menu.archive", fallback: "Archive")
      /// Delete
      internal static let delete = L10n.tr("Localizable", "menu.delete", fallback: "Delete")
      /// Guide
      internal static let guide = L10n.tr("Localizable", "menu.guide", fallback: "Guide")
      /// New
      internal static let new = L10n.tr("Localizable", "menu.new", fallback: "New")
      /// Settings
      internal static let setting = L10n.tr("Localizable", "menu.setting", fallback: "Settings")
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
