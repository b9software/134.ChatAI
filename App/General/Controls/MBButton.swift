/*
 MBButton

 Copyright © 2018, 2021, 2023 BB9z.
 Copyright © 2014 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 https://github.com/RFUI/MBAppKit

 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */

import B9Action
import UIKit

/**
 按钮基类，主要用于外观定制

 Button base class. Used mainly for appearance customization.
 */
class MBButton: UIButton {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        dispatch_async_on_main { [weak self] in
            self?.afterInit()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        dispatch_async_on_main { [weak self] in
            self?.afterInit()
        }
    }

    func onInit() {}

    func afterInit() {
        setupAppearance()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupAppearanceIfNeeded()
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        setupAppearanceIfNeeded()
    }

    override var isEnabled: Bool {
        didSet { needsUpdateState.set() }
    }
    override var isSelected: Bool {
        didSet { needsUpdateState.set() }
    }
    override var isHighlighted: Bool {
        didSet { needsUpdateState.set() }
    }
    private(set) var isHover = false {
        didSet { needsUpdateState.set() }
    }
    var isHoverEnabled = false {
        didSet {
            if oldValue == isHoverEnabled { return }
            if isHoverEnabled {
                if hoverGesture == nil {
                    let gesture = UIHoverGestureRecognizer(target: self, action: #selector(onHoverGesture))
                    addGestureRecognizer(gesture)
                    hoverGesture = gesture
                }
            }
            hoverGesture?.isEnabled = isHoverEnabled
        }
    }
    private var hoverGesture: UIGestureRecognizer?

    @objc private func onHoverGesture(_ sender: UIGestureRecognizer) {
        switch sender.state {
        case .began, .changed:
            isHover = true
        default:
            isHover = false
        }
    }

    lazy var needsUpdateState = DelayAction(Action({ [weak self] in
        guard let sf = self else { return }
        sf.updateUIForStateUpdate()
        if sf.configuration != nil {
            sf.setNeedsUpdateConfiguration()
        }
    }))

    override func tintColorDidChange() {
        super.tintColorDidChange()
        updateUIForStateUpdate()
    }

    // MARK: - Style

    /// Default do nothing
    func updateUIForStateUpdate() {
    }

    /**
     样式名，以便让同一个按钮类支持多个样式

     一般在 setupAppearance 根据 styleName 做相应配置

     Style name to support multiple styles for the same button class.

     Normally, configuration is done in setupAppearance based on styleName.
     */
    @IBInspectable var styleName: String?

    /// Subclasses override this method to set the appearance.
    ///
    /// The timing of appearance setup is as soon as possible after button initialization. It cannot be skipped during initialization using `skipAppearanceSetup` because it may override the normal business code settings too late. The timing of the nib loading is stable at awakeFromNib, and the timing of the code creation is uncertain, which can be assisted by the `isAppearanceSetupDone` property.
    ///
    /// Usually, do not call super.
    func setupAppearance() {
        // For overwrite
    }

    /// Subclasses override this method to execute when the button size changes
    func setupAppearanceAfterSizeChanged() {
        // For overwrite
    }

    /// Property to skip the appearance setup.
    @IBInspectable var skipAppearanceSetup: Bool = false

    /// Flag that indicates appearance code setup completion. Only needs to be checked when the button is created through code.
    private(set) var isAppearanceSetupDone = false

    /// Internal method to check and perform appearance setup
    private func setupAppearanceIfNeeded() {
        if isAppearanceSetupDone { return }
        isAppearanceSetupDone = true
        if !skipAppearanceSetup {
            setupAppearance()
        }
    }

    override var bounds: CGRect {
        didSet {
            if skipAppearanceSetup
                || oldValue.size == bounds.size {
                return
            }
            setupAppearanceAfterSizeChanged()
        }
    }

    override var frame: CGRect {
        didSet {
            if skipAppearanceSetup
                || oldValue.size == frame.size {
                return
            }
            setupAppearanceAfterSizeChanged()
        }
    }

    // MARK: - Touch

    /// Extensions to make the button touchable in an expanded area.
    var touchHitTestExpandInsets = UIEdgeInsets.zero {
        didSet {
            setNeedsLayout()
        }
    }
    // swiftlint:disable:next identifier_name
    @IBInspectable var _touchHitTestExpandInsets: CGRect = .zero {
        didSet {
            touchHitTestExpandInsets = NSValue(cgRect: _touchHitTestExpandInsets).uiEdgeInsetsValue
        }
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let reversedInsets = touchHitTestExpandInsets.reversed
        let expandRect = bounds.inset(by: reversedInsets)
        return expandRect.contains(point)
    }

    /**
     非空时按钮原有的点击事件不再发送，而改为执行该 block

     设计时的场景是增加一种禁用状态，可以点击但不走正常的事件
     */
    var blockTouchEvent: (() -> Void)?

    private var blockTouchEventFlag = false
    override func sendAction(_ action: Selector, to target: Any?, for event: UIEvent?) {
        if let block = blockTouchEvent,
           event?.type == .touches {
            if blockTouchEventFlag { return }
            blockTouchEventFlag = true
            block()
            dispatch_after_seconds(0) {
                self.blockTouchEventFlag = false
            }
            return
        }
        super.sendAction(action, to: target, for: event)
    }
}

/**
 作为按钮容器，解决按钮在 view 的 bounds 外不可点的问题

 Container as a button container, solving the problem of buttons not being clickable outside the view's bounds.
 */
class MBControlTouchExpandContainerView: UIView {
    @IBOutlet var controls: [UIControl]?

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let controls = controls else {
            return super.point(inside: point, with: event)
        }
        for c in controls {
            let convertedPoint = c.convert(point, from: self)
            if c.point(inside: convertedPoint, with: event) {
                return true
            }
        }
        return super.point(inside: point, with: event)
    }
}
