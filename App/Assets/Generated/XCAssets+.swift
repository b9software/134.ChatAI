// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal enum Background {
    internal static let box = ColorAsset(name: "Background/Box")
    internal static let cell = ColorAsset(name: "Background/Cell")
    internal static let page = ColorAsset(name: "Background/Page")
    internal static let settingPage = ColorAsset(name: "Background/SettingPage")
    internal static let sidebar = ColorAsset(name: "Background/Sidebar")
  }
  internal enum Button {
    internal static let stdBase = ColorAsset(name: "Button/StdBase")
    internal static let stdHover = ColorAsset(name: "Button/StdHover")
  }
  internal enum GeneralUI {
    internal enum Block {
      internal static let blank = ImageAsset(name: "blank")
      internal static let solid = ImageAsset(name: "solid")
      internal static let underline1px = ImageAsset(name: "underline_1px")
    }
    internal enum Control {
      internal static let buttonRect = ImageAsset(name: "button_rect")
      internal static let buttonRound44Fill = ImageAsset(name: "button_round44_fill")
      internal static let buttonRound44Frame = ImageAsset(name: "button_round44_frame")
      internal static let checkboxOff = ImageAsset(name: "checkbox_off")
      internal static let checkboxOn = ImageAsset(name: "checkbox_on")
      internal static let tickSliderThumb = ImageAsset(name: "tick_slider_thumb")
    }
    internal enum Input {
      internal static let inputBox = ImageAsset(name: "input_box")
      internal static let textFieldBgDisabled = ImageAsset(name: "text_field_bg_disabled")
      internal static let textFieldBgFocused = ImageAsset(name: "text_field_bg_focused")
      internal static let textFieldBgNormal = ImageAsset(name: "text_field_bg_normal")
    }
    internal enum Navigation {
      internal static let navBack = ImageAsset(name: "nav_back")
      internal static let navBackLayoutfix = ImageAsset(name: "nav_back_layoutfix")
    }
    internal static let avatarPlaceholder = ImageAsset(name: "avatar_placeholder")
  }
  internal enum Icon {
    internal static let archivebox = ImageAsset(name: "Icon/archivebox")
    internal static let gearBadge = ImageAsset(name: "Icon/gear-badge")
    internal static let gear = ImageAsset(name: "Icon/gear")
    internal static let infoBubble = ImageAsset(name: "Icon/info-bubble")
    internal static let test16 = ImageAsset(name: "Icon/test16")
    internal static let test24 = ImageAsset(name: "Icon/test24")
    internal static let trash = ImageAsset(name: "Icon/trash")
    internal static let xmark = ImageAsset(name: "Icon/xmark")
  }
  internal enum LegacyColor {
    internal static let accentColor = ColorAsset(name: "AccentColor")
    internal static let placeholder = ColorAsset(name: "placeholder")
    internal static let shadow = ColorAsset(name: "shadow")
  }
  internal enum List {
    internal static let listAccessory10 = ImageAsset(name: "list_accessory10")
    internal static let tableRefreshIndicator = ImageAsset(name: "table_refresh_indicator")
  }
  internal enum Text {
    internal static let first = ColorAsset(name: "Text/First")
    internal static let second = ColorAsset(name: "Text/Second")
    internal static let thrid = ColorAsset(name: "Text/Thrid")
  }
  internal static let cursorsResizeBoth = ImageAsset(name: "cursors_resize_both")
  internal static let cursorsResizeLeft = ImageAsset(name: "cursors_resize_left")
  internal static let cursorsResizeRight = ImageAsset(name: "cursors_resize_right")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  #if os(iOS) || os(tvOS)
  @available(iOS 11.0, tvOS 11.0, *)
  internal func color(compatibleWith traitCollection: UITraitCollection) -> Color {
    let bundle = BundleToken.bundle
    guard let color = Color(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal private(set) lazy var swiftUIColor: SwiftUI.Color = {
    SwiftUI.Color(asset: self)
  }()
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Color {
  init(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }
}
#endif

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  internal func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

internal extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Image {
  init(asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }

  init(asset: ImageAsset, label: Text) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
