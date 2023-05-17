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
    /// Cancel
    internal static let cancel = L10n.tr("Localizable", "cancel", fallback: "Cancel")
    /// Proccess text with ${applicationName}
    internal static let proccessTextWithApplicationName = L10n.tr("Localizable", "Proccess text with ${applicationName}", fallback: "Proccess text with ${applicationName}")
    /// Send ${text} to ${conversation}
    internal static let sendTextToConversation = L10n.tr("Localizable", "Send ${text} to ${conversation}", fallback: "Send ${text} to ${conversation}")
    /// Send text to ${applicationName}
    internal static let sendTextToApplicationName = L10n.tr("Localizable", "Send text to ${applicationName}", fallback: "Send text to ${applicationName}")
    internal enum App {
      /// B9ChatAI
      internal static let name = L10n.tr("Localizable", "app.name", fallback: "B9ChatAI")
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
      /// ...
      internal static let loading = L10n.tr("Localizable", "chat.loading", fallback: "...")
      /// Waiting....
      internal static let loadingQueue = L10n.tr("Localizable", "chat.loadingQueue", fallback: "Waiting....")
      /// You must set up the engine before you can chat.
      internal static let setupBeforeUseNotice = L10n.tr("Localizable", "chat.setupBeforeUseNotice", fallback: "You must set up the engine before you can chat.")
      /// Unarchive
      internal static let unArchive = L10n.tr("Localizable", "chat.unArchive", fallback: "Unarchive")
      internal enum Reply {
        /// ⚠️ You have selected a message in the middle of a context, continue send will drop all messages behind it.
        internal static let dropContextWarning = L10n.tr("Localizable", "chat.reply.dropContextWarning", fallback: "⚠️ You have selected a message in the middle of a context, continue send will drop all messages behind it.")
        /// Continue %@
        internal static func selectionContinue(_ p1: Any) -> String {
          return L10n.tr("Localizable", "chat.reply.selectionContinue", String(describing: p1), fallback: "Continue %@")
        }
        /// Continue Selection?
        internal static let wantContinue = L10n.tr("Localizable", "chat.reply.wantContinue", fallback: "Continue Selection?")
      }
      internal enum Send {
        /// Unable load conversation engine.
        internal static let engineNoLoad = L10n.tr("Localizable", "chat.send.engineNoLoad", fallback: "Unable load conversation engine.")
        /// Conversation engine has not been set.
        internal static let engineNotSet = L10n.tr("Localizable", "chat.send.engineNotSet", fallback: "Conversation engine has not been set.")
      }
      internal enum Setting {
        /// The same ID already exists.
        internal static let badSameID = L10n.tr("Localizable", "chat.setting.badSameID", fallback: "The same ID already exists.")
        /// Please choose a engine.
        internal static let choiceEngine = L10n.tr("Localizable", "chat.setting.choiceEngine", fallback: "Please choose a engine.")
        /// Please choose a model.
        internal static let choiceModel = L10n.tr("Localizable", "chat.setting.choiceModel", fallback: "Please choose a model.")
        /// Clear
        internal static let clearAlertConfirm = L10n.tr("Localizable", "chat.setting.clearAlertConfirm", fallback: "Clear")
        /// This operation can't be undone.
        internal static let clearAlertMessage = L10n.tr("Localizable", "chat.setting.clearAlertMessage", fallback: "This operation can't be undone.")
        /// Clear all messages in this conversation?
        internal static let clearAlertTitle = L10n.tr("Localizable", "chat.setting.clearAlertTitle", fallback: "Clear all messages in this conversation?")
        /// This engine is missing the API key, please update it or choose another one.
        internal static let engineMissingKey = L10n.tr("Localizable", "chat.setting.engineMissingKey", fallback: "This engine is missing the API key, please update it or choose another one.")
        /// Fetching models...
        internal static let modelFetching = L10n.tr("Localizable", "chat.setting.modelFetching", fallback: "Fetching models...")
        /// This engine is anomalous.
        internal static let selectBadEngine = L10n.tr("Localizable", "chat.setting.selectBadEngine", fallback: "This engine is anomalous.")
        /// More focused and deterministic.
        internal static let temperatureTipLower = L10n.tr("Localizable", "chat.setting.temperatureTipLower", fallback: "More focused and deterministic.")
        /// Balanced output.
        internal static let temperatureTipStand = L10n.tr("Localizable", "chat.setting.temperatureTipStand", fallback: "Balanced output.")
        /// More interesting and creative.
        internal static let temperatureTipUpper = L10n.tr("Localizable", "chat.setting.temperatureTipUpper", fallback: "More interesting and creative.")
        /// Sticks to the most likely words and phrases.
        internal static let topPossibleTipLower = L10n.tr("Localizable", "chat.setting.topPossibleTipLower", fallback: "Sticks to the most likely words and phrases.")
        /// Allowed choose from a wider range of words and phrases.
        internal static let topPossibleTipUpper = L10n.tr("Localizable", "chat.setting.topPossibleTipUpper", fallback: "Allowed choose from a wider range of words and phrases.")
      }
    }
    internal enum Engine {
      internal enum Create {
        /// Please input a valid API key.
        internal static let noKeyGiven = L10n.tr("Localizable", "engine.create.no-key-given", fallback: "Please input a valid API key.")
        /// Please input a valid proxy address.
        internal static let noProxyAddressGiven = L10n.tr("Localizable", "engine.create.no-proxy-address-given", fallback: "Please input a valid proxy address.")
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
          /// Engine with the same proxy config already exist.
          internal static let existProxy = L10n.tr("Localizable", "engine.create.fail.exist-proxy", fallback: "Engine with the same proxy config already exist.")
          /// Unable to generate secure data for key.
          internal static let hashKey = L10n.tr("Localizable", "engine.create.fail.hash-key", fallback: "Unable to generate secure data for key.")
        }
        internal enum TypeOpenai {
          /// Use offical OpenAI API
          internal static let detail = L10n.tr("Localizable", "engine.create.type-openai.detail", fallback: "Use offical OpenAI API")
          /// ChatGPT / OpenAI
          internal static let title = L10n.tr("Localizable", "engine.create.type-openai.title", fallback: "ChatGPT / OpenAI")
        }
        internal enum TypeOpenaiProxy {
          /// Use a proxy server foward requests to OpenAI API
          internal static let detail = L10n.tr("Localizable", "engine.create.type-openai-proxy.detail", fallback: "Use a proxy server foward requests to OpenAI API")
          /// ChatGPT / API Proxy
          internal static let title = L10n.tr("Localizable", "engine.create.type-openai-proxy.title", fallback: "ChatGPT / API Proxy")
        }
      }
    }
    internal enum GenralError {
      /// "%@" is not a valid URL.
      internal static func invalidUrl(_ p1: Any) -> String {
        return L10n.tr("Localizable", "genral-error.invalid-url", String(describing: p1), fallback: "\"%@\" is not a valid URL.")
      }
    }
    internal enum Guide {
      /// https://github.com/b9software/B9ChatAI/wiki/Inter-App-Communication
      internal static let interCommunicationLink = L10n.tr("Localizable", "guide.interCommunicationLink", fallback: "https://github.com/b9software/B9ChatAI/wiki/Inter-App-Communication")
      /// Dear user,
      /// 
      /// Thank you for downloading my app. Currently, an OpenAI account or API key is required to use the app. However, I will be adding support for more engines in the future.
      /// 
      /// Please note that this application is still in the early stages of development. In addition to the current features, many more are still in progress. I appreciate your patience and understanding as I work to improve the app.
      /// 
      /// For a list of known issues, please refer to the following link:
      ///  https://github.com/b9software/B9ChatAI/issues/1
      /// 
      /// Thank you for your understanding and support.
      /// 
      /// Best regards,
      /// 
      /// BB9z
      /// 
      /// 2023-04-16
      internal static let text1st = L10n.tr("Localizable", "guide.text1st", fallback: "Dear user,\n\nThank you for downloading my app. Currently, an OpenAI account or API key is required to use the app. However, I will be adding support for more engines in the future.\n\nPlease note that this application is still in the early stages of development. In addition to the current features, many more are still in progress. I appreciate your patience and understanding as I work to improve the app.\n\nFor a list of known issues, please refer to the following link:\n https://github.com/b9software/B9ChatAI/issues/1\n\nThank you for your understanding and support.\n\nBest regards,\n\nBB9z\n\n2023-04-16")
    }
    internal enum Link {
      /// https://github.com/b9software/B9ChatAI/discussions
      internal static let feedback = L10n.tr("Localizable", "link.feedback", fallback: "https://github.com/b9software/B9ChatAI/discussions")
      /// https://github.com/b9software/B9ChatAI
      internal static let homePage = L10n.tr("Localizable", "link.homePage", fallback: "https://github.com/b9software/B9ChatAI")
      /// https://github.com/b9software/B9ChatAI/wiki/
      internal static let userManual = L10n.tr("Localizable", "link.userManual", fallback: "https://github.com/b9software/B9ChatAI/wiki/")
      internal enum HuggingChat {
        /// https://huggingface.co/chat/privacy
        internal static let privacy = L10n.tr("Localizable", "link.huggingChat.privacy", fallback: "https://huggingface.co/chat/privacy")
      }
      internal enum Openai {
        /// https://platform.openai.com/account/api-keys
        internal static let apiKeys = L10n.tr("Localizable", "link.openai.api-keys", fallback: "https://platform.openai.com/account/api-keys")
        /// 
        internal static let knownProxy = L10n.tr("Localizable", "link.openai.known-proxy", fallback: "")
        /// https://openai.com/policies/privacy-policy
        internal static let privacy = L10n.tr("Localizable", "link.openai.privacy", fallback: "https://openai.com/policies/privacy-policy")
        /// https://openai.com/policies/terms-of-use
        internal static let tos = L10n.tr("Localizable", "link.openai.tos", fallback: "https://openai.com/policies/terms-of-use")
      }
    }
    internal enum Menu {
      /// Archive
      internal static let archive = L10n.tr("Localizable", "menu.archive", fallback: "Archive")
      /// Continue Last Topic
      internal static let continueLastTopic = L10n.tr("Localizable", "menu.continueLastTopic", fallback: "Continue Last Topic")
      /// Delete
      internal static let delete = L10n.tr("Localizable", "menu.delete", fallback: "Delete")
      /// Feedback
      internal static let feedback = L10n.tr("Localizable", "menu.feedback", fallback: "Feedback")
      /// Float Mode
      internal static let floatMode = L10n.tr("Localizable", "menu.floatMode", fallback: "Float Mode")
      /// Collapse Float Window
      internal static let floatModeCollapse = L10n.tr("Localizable", "menu.floatModeCollapse", fallback: "Collapse Float Window")
      /// Exit Float Mode
      internal static let floatModeExit = L10n.tr("Localizable", "menu.floatModeExit", fallback: "Exit Float Mode")
      /// Expand Float Window
      internal static let floatModeExpand = L10n.tr("Localizable", "menu.floatModeExpand", fallback: "Expand Float Window")
      /// Focus on Input
      internal static let focusInput = L10n.tr("Localizable", "menu.focusInput", fallback: "Focus on Input")
      /// Guide
      internal static let guide = L10n.tr("Localizable", "menu.guide", fallback: "Guide")
      /// Help
      internal static let help = L10n.tr("Localizable", "menu.help", fallback: "Help")
      /// Project on GitHub
      internal static let homePage = L10n.tr("Localizable", "menu.homePage", fallback: "Project on GitHub")
      /// Copy Browser Bookmark
      internal static let integrationBookmark = L10n.tr("Localizable", "menu.integrationBookmark", fallback: "Copy Browser Bookmark")
      /// What's this?
      internal static let integrationHelp = L10n.tr("Localizable", "menu.integrationHelp", fallback: "What's this?")
      /// Go Back
      internal static let navigationBack = L10n.tr("Localizable", "menu.navigationBack", fallback: "Go Back")
      /// New
      internal static let new = L10n.tr("Localizable", "menu.new", fallback: "New")
      /// Operation
      internal static let operation = L10n.tr("Localizable", "menu.operation", fallback: "Operation")
      /// Retry
      internal static let retry = L10n.tr("Localizable", "menu.retry", fallback: "Retry")
      /// Send Input
      internal static let send = L10n.tr("Localizable", "menu.send", fallback: "Send Input")
      /// Settings
      internal static let setting = L10n.tr("Localizable", "menu.setting", fallback: "Settings")
      /// Application Settings
      internal static let settingApp = L10n.tr("Localizable", "menu.settingApp", fallback: "Application Settings")
      /// Conversation Settings
      internal static let settingChat = L10n.tr("Localizable", "menu.settingChat", fallback: "Conversation Settings")
      /// Online User Manual
      internal static let userManual = L10n.tr("Localizable", "menu.userManual", fallback: "Online User Manual")
      internal enum New {
        /// Conversation
        internal static let conversation = L10n.tr("Localizable", "menu.new.conversation", fallback: "Conversation")
        /// Window Tab
        internal static let tab = L10n.tr("Localizable", "menu.new.tab", fallback: "Window Tab")
        /// Window
        internal static let window = L10n.tr("Localizable", "menu.new.window", fallback: "Window")
      }
    }
    internal enum SendIntent {
      /// Chat
      internal static let category = L10n.tr("Localizable", "sendIntent.category", fallback: "Chat")
      /// Which conversation the text send to.
      internal static let conversationDesc = L10n.tr("Localizable", "sendIntent.conversationDesc", fallback: "Which conversation the text send to.")
      /// Choosed conversation is invaild.
      internal static let conversationInvalid = L10n.tr("Localizable", "sendIntent.conversationInvalid", fallback: "Choosed conversation is invaild.")
      /// Conversation
      internal static let conversationTitle = L10n.tr("Localizable", "sendIntent.conversationTitle", fallback: "Conversation")
      /// Send text to speifiy conversation. Returns AI response after a while.
      internal static let desc = L10n.tr("Localizable", "sendIntent.desc", fallback: "Send text to speifiy conversation. Returns AI response after a while.")
      /// text,AI,chat,conversation
      internal static let searchKeyword = L10n.tr("Localizable", "sendIntent.searchKeyword", fallback: "text,AI,chat,conversation")
      /// The content send to the conversation.
      internal static let textDesc = L10n.tr("Localizable", "sendIntent.textDesc", fallback: "The content send to the conversation.")
      /// Input is empty. Input some new text
      internal static let textRequest = L10n.tr("Localizable", "sendIntent.textRequest", fallback: "Input is empty. Input some new text")
      /// Text
      internal static let textTitle = L10n.tr("Localizable", "sendIntent.textTitle", fallback: "Text")
      /// Get Response from AI
      internal static let title = L10n.tr("Localizable", "sendIntent.title", fallback: "Get Response from AI")
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
