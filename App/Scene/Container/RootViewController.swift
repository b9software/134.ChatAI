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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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

    override func restoreUserActivityState(_ activity: NSUserActivity) {
        super.restoreUserActivityState(activity)
        debugPrint(activity.activityType)
        debugPrint(activity.userInfo)
    }

    override func updateUserActivityState(_ activity: NSUserActivity) {
        super.updateUserActivityState(activity)
    }

    private func adjustTraitCollection() {
        let size = view.bounds.size

        #if targetEnvironment(macCatalyst)
        if let titleBar = view.window?.windowScene?.titlebar {
            let style: UITitlebarToolbarStyle = size.height > 500 ? .unified : .unifiedCompact
            if titleBar.toolbarStyle != style {
                titleBar.toolbarStyle = style
            }
        }
        #endif

        guard let vc = children.first else { return }

        let currentCollection = overrideTraitCollection(forChild: vc) ?? .current
        let hClass = size.width > 500 ? UIUserInterfaceSizeClass.regular : .compact
        let vClass = size.height > 500 ? UIUserInterfaceSizeClass.regular : .compact
        if currentCollection.horizontalSizeClass == hClass,
           currentCollection.verticalSizeClass == vClass {
            return
        }
        let horizontal = UITraitCollection(horizontalSizeClass: hClass)
        let vertical = UITraitCollection(verticalSizeClass: vClass)
        let collection = UITraitCollection(traitsFrom: [currentCollection, horizontal, vertical])
        setOverrideTraitCollection(collection, forChild: vc)
    }

    func focusSidebar() {
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
}

// MARK: - Actions
extension RootViewController {
    override func responds(to aSelector: Selector!) -> Bool {
        if aSelector == #selector(toolbarBack) {
            return navigator.viewControllers.count > 1
        }
        return super.responds(to: aSelector)
    }

    @IBAction func toolbarBack(_ sender: Any) {
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
        navigator.pushViewController(EngineManageViewController.newFromStoryboard(), animated: true)
    }

    @IBAction func orderFrontStandardAboutPanel(_ sender: Any) {
        navigator.pushViewController(AboutViewController.newFromStoryboard(), animated: true)
    }
}
