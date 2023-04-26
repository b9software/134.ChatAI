//
//  RootViewController.swift
//  App
//

import B9Action
import B9Condition
import UIKit

/**
 作为应用全局根 view controller

 内嵌主导航，这样如需遮盖导航的弹窗，可以加入到这里，比如启动闪屏、教程弹窗

 As the application global root view controller.

 Embed the main navigation view controller. Any pop-ups that need to cover the main navigation can be added here. Eg: splash, tutorial pop-ups.
 */
class RootViewController: B9RootViewController {

    private(set) var navigator: NavigationController!
    private(set) var split: SplitViewController!
    weak var sidebar: SidebarViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        split = children.first { $0 is SplitViewController } as? SplitViewController
        navigator = split.children.first { $0 is NavigationController } as? NavigationController
        sidebar = split.children.first { $0 is SidebarViewController } as? SidebarViewController
        #if targetEnvironment(macCatalyst)
        navigator.setNavigationBarHidden(true, animated: false)
        #endif
        navigator.onViewControllerChanged = { [weak self] in
            self?.sidebar?.onNavigatorStackChanged($0)
        }
        restoreUserActivity()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustTraitCollection), name: UIContentSizeCategory.didChangeNotification, object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIContentSizeCategory.didChangeNotification, object: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustTraitCollection()
    }

    private func restoreUserActivity() {
        guard let activity = userActivity,
              let type = UserActivityType(rawValue: activity.activityType) else {
            return
        }
        switch type {
        case .setting:
            gotoSetting(self)
        case .guide:
            gotoGuide(self)
        case .conversation:
            guard let id = activity.userInfo?["id"] as? StringID else {
                AppLog().warning("Request conversation activity but no id.")
                return
            }
            Conversation.load(id: id) { [weak self] result in
                Do.try {
                    guard let sf = self else { return }
                    let item = try result.get()
                    sf.gotoChatDetail(item: item)
                }
            }
        case .newConversation:
            assert(false, "todo")
        }
    }

    @objc private func adjustTraitCollection() {
        let size = view.bounds.size

        #if targetEnvironment(macCatalyst)
        SceneDelegate.of(view)?.setPreferedToolbarStyleDueToLayout(style: size.height > 500 ? .unified : .unifiedCompact)
        #endif

        guard children.isNotEmpty else { return }

        let hClass = size.width > 500 ? UIUserInterfaceSizeClass.regular : .compact
        let vClass = size.height > 500 ? UIUserInterfaceSizeClass.regular : .compact
        let sizeCategory = Current.defualts.preferredContentSize

        for vc in children {
            let currentCollection = overrideTraitCollection(forChild: vc) ?? .current
            if currentCollection.horizontalSizeClass == hClass,
               currentCollection.verticalSizeClass == vClass,
               currentCollection.preferredContentSizeCategory == sizeCategory {
                return
            }
            let collection = UITraitCollection(traitsFrom: [
                currentCollection,
                .init(horizontalSizeClass: hClass),
                .init(verticalSizeClass: vClass),
                .init(preferredContentSizeCategory: sizeCategory),
            ])
            setOverrideTraitCollection(collection, forChild: vc)
        }
    }

    func focusSidebar() {
        if split.isCollapsed { return }
        if let system = UIFocusSystem.focusSystem(for: self),
           let element = sidebar?.preferredFocusEnvironments.first {
            system.requestFocusUpdate(to: element)
            sidebar?.becomeFirstResponder()
        }
    }

    func focusSidebarDetail() {
        if let system = UIFocusSystem.focusSystem(for: self),
           let element = navigator?.visibleViewController?.preferredFocusEnvironments.first {
            system.requestFocusUpdate(to: element)
            var responder = element as? UIResponder
            while responder != nil {
                if responder?.becomeFirstResponder() == true {
                    AppLog().debug("In focusSidebarDetail, \(responder!) did becomeFirstResponder.")
                    break
                }
                responder = responder?.next
            }
        }
    }

    override var userActivity: NSUserActivity? {
        didSet {
            oldValue?.invalidate()
            userActivity?.becomeCurrent()
            if isViewLoaded,
               let scene = view.window?.windowScene {
                scene.userActivity = userActivity
            }
        }
    }

    var floatModeState = FloatModeState.normal {
        didSet {
            AppLog().debug("RootVC> Float mode: \(floatModeState)")
        }
    }
}

// MARK: - Actions
extension RootViewController {
    override func responds(to aSelector: Selector!) -> Bool {
        if aSelector == #selector(goBack) {
            return navigator.viewControllers.count > 1
        }
        if super.responds(to: aSelector) { return true }
        if navigator?.visibleViewController?.responds(to: aSelector) == true { return true }
        return false
    }

    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        if let detail = navigator?.visibleViewController,
           detail.responds(to: aSelector) {
            return detail
        }
        return super.forwardingTarget(for: aSelector)
    }

    @IBAction func goBack(_ sender: Any) {
        navigator.popViewController(animated: true)
    }

    // StandardActions
    @IBAction func newConversation(_ sender: Any?) {
        Current.conversationManager.createNew()
    }

    func gotoWelcome() {
        navigator.setViewControllers([WelcomeViewController.newFromStoryboard()], animated: false)
    }

    func tryActiveConversation(id: StringID?) {
        guard let id = id else {
            if navigator.visibleViewController is ConversationDetailViewController {
                return
            }
            if let first = Current.conversationManager.listItems.first {
                gotoChatDetail(item: first)
            }
            return
        }
        if let vc = navigator.visibleViewController as? ConversationDetailViewController,
           vc.item.id == id {
            return
        }
        if let item = Current.conversationManager.listItems.first(where: { $0.id == id }) {
            gotoChatDetail(item: item)
        }
    }

    func gotoChatDetail(item: Conversation) {
        userActivity = NSUserActivity(conversationID: item.id)
        if let vc = navigator.visibleViewController as? ConversationDetailViewController {
            if vc.item == item {
                return
            }
        }
        let vc = ConversationDetailViewController.newFromStoryboard()
        vc.item = item
        navigator.setViewControllers([vc], animated: false)
    }

    @IBAction private func gotoGuide(_ sender: Any) {
        userActivity = NSUserActivity(.guide)
        navigator.setViewControllers([GuideViewController.newFromStoryboard()], animated: false)
    }

    @IBAction func gotoSetting(_ sender: Any) {
        userActivity = NSUserActivity(.setting)
        if let _ = navigator.visibleViewController as? SettingViewController {
            return
        }
        navigator.setViewControllers([SettingViewController.newFromStoryboard()], animated: false)
    }

    @IBAction private func pushEngineManage(_ sender: Any) {
        userActivity = NSUserActivity(.setting)
        navigator.pushViewController(EngineCreateTypeViewController.newFromStoryboard(), animated: true)
    }

    @IBAction func orderFrontStandardAboutPanel(_ sender: Any) {
        navigator.pushViewController(AboutViewController.newFromStoryboard(), animated: true)
    }
}
