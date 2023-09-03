//
//  SplitViewController.swift
//  B9ChatAI
//
//  Created by BB9z on 2023/3/20.
//  Copyright © 2023 B9Software. All rights reserved.
//

import UIKit

class SplitViewController:
    UIViewController,
    GeneralSceneActivationAutoForward
{
    @IBOutlet private weak var sidebarContainer: UIView!
    @IBOutlet private weak var detailContainer: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        initWidth()
        updateUI(compact: view.width < becomeCompactWidth)
        updateUI(isCollapsed: isCollapsed)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setNeedsUpdateCompact()
    }

    // MARK: - Collapsed

    /// Sidebar collapsed
    var isCollapsed: Bool {
        !view.bounds.contains(sidebarContainer.frame)
    }

    func updateUI(isCollapsed: Bool) {
        if compactMode {
            compactSidebarPosition.constant = isCollapsed ? -sidebarContainer.width : 0
            compactTouchMask.alpha = isCollapsed ? 0 : 1
            compactTouchMask.isHidden = false
        } else {
            separatorLeading.constant = isCollapsed ? -1 : lastSidebarWidth
            separatorDragger.isHidden = isCollapsed
            compactTouchMask.isHidden = true
        }
    }

    @IBAction func toggleSidebar(_ sender: Any?) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animated: isViewAppeared, beforeAnimations: nil) { [self] in
            updateUI(isCollapsed: !isCollapsed)
            view.layoutIfNeeded()
        }
    }

    // MARK: - Compact
    private(set) var compactMode = false
    @IBInspectable var becomeCompactWidth: CGFloat = 800

    @IBOutlet private weak var compactTouchMask: UIView!
    @IBOutlet private weak var compactSidebarPosition: NSLayoutConstraint!
    @IBOutlet private var compactConstraints: [NSLayoutConstraint]!
    @IBOutlet private var regularConstraints: [NSLayoutConstraint]!

    func compactMode(enabled: Bool, animated: Bool) {
        if compactMode == enabled { return }
        compactMode = enabled
        if !isCollapsed {
            updateUI(isCollapsed: true)
        }
        if !animated {
            updateUI(compact: enabled)
            return
        }
        UIView.animate(withDuration: 0.1, animations: { [self] in
            updateUI(compact: enabled)
            view.layoutIfNeeded()
        })
    }

    private func updateUI(compact enabled: Bool) {
        separatorDragger.isHidden = enabled
        separatorLeading.constant = enabled ? -1 : lastSidebarWidth
        if enabled {
            view.insertSubview(sidebarContainer, aboveSubview: compactTouchMask ?? detailContainer)
            NSLayoutConstraint.deactivate(regularConstraints ?? [])
            NSLayoutConstraint.activate(compactConstraints ?? [])
        } else {
            view.insertSubview(sidebarContainer, belowSubview: separator ?? detailContainer)
            NSLayoutConstraint.deactivate(compactConstraints ?? [])
            NSLayoutConstraint.activate(regularConstraints ?? [])
        }
    }

    func setNeedsUpdateCompact() {
        let shouldCompact = view.width < becomeCompactWidth
        compactMode(enabled: shouldCompact, animated: isViewAppeared)
    }

    @IBAction private func onTouchCompactMask(_ sender: Any) {
        toggleSidebar(sender)
    }

    // MARK: - Width

    @IBInspectable var sidebarMinimalWidth: CGFloat = 200
    @IBInspectable var sidebarMaximumWidth: CGFloat = 500

    /// 设置后保存宽度
    @IBInspectable var widthKey: String?
    @IBOutlet private weak var sidebarWidth: NSLayoutConstraint!

    var lastSidebarWidth: CGFloat = 200 {
        didSet {
            if let key = widthKey {
                UserDefaults.standard.set(lastSidebarWidth, forKey: key)
            }
        }
    }

    private func initWidth() {
        var width = sidebarContainer.width
        if let key = widthKey {
            width = CGFloat(UserDefaults.standard.float(forKey: key))
        }
        updateDrag(point: CGPoint(x: width, y: 0))
    }

    // MARK: - Drag

    @IBOutlet private weak var separator: UIView?
    @IBOutlet private weak var separatorDragger: SplitSeparatorDraggerView!
    @IBOutlet private weak var separatorLeading: NSLayoutConstraint!

    @IBAction func onSeparatorDrag(_ sender: UIPanGestureRecognizer) {
        let point = sender.location(in: view)
        switch sender.state {
        case .changed:
            updateDrag(point: point)
        default:
            break
        }
    }

    internal func updateDrag(point: CGPoint) {
        assert(!compactMode)
        var width = point.x
        if width < sidebarMinimalWidth {
            // update indicator
            width = sidebarMinimalWidth
        }
        if width > sidebarMaximumWidth {
            // update indicator
            width = sidebarMaximumWidth
        }
        if separatorLeading.constant == width { return }
        separatorLeading.constant = width
        sidebarWidth.constant = width
        lastSidebarWidth = sidebarWidth.constant
    }
}

class SplitSeparatorDraggerView: UIView, UIGestureRecognizerDelegate {
    @IBOutlet private weak var cursorsView: UIImageView!
    @IBOutlet private weak var separator: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        let gesture = UIHoverGestureRecognizer(target: self, action: #selector(onHover))
        gesture.delegate = self
        addGestureRecognizer(gesture)
        cursorsView.sizeToFit()
        cursorsView.isHidden = true
    }

    @IBAction private func onHover(_ sender: UIHoverGestureRecognizer) {
        switch sender.state {
        case .began, .changed:
            separator?.backgroundColor = .tintColor
            cursorsView.isHidden = false
            var point = sender.location(in: self)
            point.y -= 10
            cursorsView.center = point
        case .ended, .cancelled:
            separator?.backgroundColor = .separator
            cursorsView.isHidden = true
        default:
            break
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let hasHover = gestureRecognizer is UIHoverGestureRecognizer || otherGestureRecognizer is UIHoverGestureRecognizer
        let hasPan = gestureRecognizer is UIPanGestureRecognizer || otherGestureRecognizer is UIPanGestureRecognizer
        return hasHover && hasPan
    }
}
