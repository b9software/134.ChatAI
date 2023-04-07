/*
 应用级别的按钮定制
 */

/**
 应用级别按钮
 */
class Button: MBButton {
    /**
     定义样式名
     
     一般在 Interface Builder 中通过 styleName 设置
     */
    enum Style: String {
        /// 默认按钮，灰色，高亮 tintColor
        case std

        /// 圆弧线框，颜色随 tintColor 改变
        case round
    }

    var style: Style?

    override func setupAppearance() {
        guard let style = Style(rawValue: styleName ?? "") else { return }
        self.style = style
        switch style {
        case .std:
            if configuration == nil {
                configuration = UIButton.Configuration.filled()
            }
            configuration?.buttonSize = .large
            configuration?.baseForegroundColor = Asset.Text.first.color
            isHoverEnabled = true

        case .round:
            setTitleColor(.white, for: .selected)
            setTitleColor(.white, for: .disabled)
            updateRoundStyleIfNeeded()
        }
    }

    override func setupAppearanceAfterSizeChanged() {
        updateRoundStyleIfNeeded()
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        updateRoundStyleIfNeeded()
    }

    func updateRoundStyleIfNeeded() {
        guard style == .round else { return }
        let size = height
        guard size > 0 else { return }
        let roundInset = UIEdgeInsetsMakeWithSameMargin(size / 2)
        let resizeInset = UIEdgeInsets(top: 0, left: size / 2 + 1, bottom: 0, right: size / 2 + 1)
        let bgSize = CGSize(width: size + 3, height: size)
        let normalBG = RFDrawImage.image(withRoundingCorners: roundInset, size: bgSize, fill: .white, stroke: tintColor, strokeWidth: 1, boxMargin: .zero, resizableCapInsets: resizeInset, scaleFactor: 0)
        setBackgroundImage(normalBG, for: .normal)
        setTitleColor(tintColor, for: .normal)

        let highlghtColor = tintColor.rf_lighter()
        let highlightBG = RFDrawImage.image(withRoundingCorners: roundInset, size: bgSize, fill: .white, stroke: highlghtColor, strokeWidth: 1, boxMargin: .zero, resizableCapInsets: resizeInset, scaleFactor: 0)
        setBackgroundImage(highlightBG, for: .highlighted)
        setTitleColor(highlghtColor, for: .highlighted)

        let selectedBG = RFDrawImage.image(withRoundingCorners: roundInset, size: bgSize, fill: tintColor, stroke: nil, strokeWidth: 0, boxMargin: .zero, resizableCapInsets: resizeInset, scaleFactor: 0)
        setBackgroundImage(selectedBG, for: .selected)

        let disableBG = RFDrawImage.image(withRoundingCorners: roundInset, size: bgSize, fill: UIColor(named: "button_disabled")!, stroke: nil, strokeWidth: 0, boxMargin: .zero, resizableCapInsets: resizeInset, scaleFactor: 0)
        setBackgroundImage(disableBG, for: .disabled)
    }

    override func updateConfiguration() {
        super.updateConfiguration()
        if let image = image(for: state) {
            configuration?.image = image
        }
        if state == .disabled {
            setBackground(color: Asset.Button.stdBase.color.withAlphaComponent(0.5))
            return
        }
        if state == .highlighted || state == .selected {
            setBackground(color: tintColor)
            return
        }
        if isHover {
            setBackground(color: Asset.Button.stdHover.color)
            return
        }
        setBackground(color: Asset.Button.stdBase.color)
    }

    func setBackground(color: UIColor?) {
        configuration?.background.backgroundColor = color
    }

    // MARK: -

    /// 按钮选中时加粗
    @IBInspectable var boldWhenSelected: Bool = false
    /// 按钮选中时字号增大
    @IBInspectable var scaleWhenSelected: CGFloat = 0
    private var normalFontSizeCached: CGFloat?
    private var normalFontSize: CGFloat {
        if let c = normalFontSizeCached {
            return c
        }
        let size = titleLabel?.font.pointSize ?? UIFont.labelFontSize
        normalFontSizeCached = size.rounded()
        return size
    }

    override var isSelected: Bool {
        didSet {
            guard boldWhenSelected || scaleWhenSelected > 0 else { return }
            var size = normalFontSize
            if isSelected && scaleWhenSelected > 0 {
                size *= scaleWhenSelected
            }
            titleLabel?.font = UIFont.systemFont(ofSize: size, weight: isSelected ? .semibold : .regular)
        }
    }

    // MARK: - Hover
    var isHover = false
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
        setNeedsUpdateConfiguration()
    }

    override var canBecomeFocused: Bool { true }
}
