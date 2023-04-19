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

        /// 可高亮的选项用
        case selection

        case action
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
            configuration?.baseForegroundColor = Asset.Text.first.color
            isHoverEnabled = true

        case .round:
            setTitleColor(.white, for: .selected)
            setTitleColor(.white, for: .disabled)
            updateRoundStyleIfNeeded()

        case .selection, .action:
            assert(configuration == nil)
            updateRoundStyleIfNeeded()
            isHoverEnabled = true
        }
    }

    override func setupAppearanceAfterSizeChanged() {
        updateRoundStyleIfNeeded()
    }

    private func updateRoundStyleIfNeeded() {
        if style == .selection || style == .action {
            layer.cornerRadius = height / 2
        }
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
            if boldWhenSelected || scaleWhenSelected > 0 {
                var size = normalFontSize
                if isSelected && scaleWhenSelected > 0 {
                    size *= scaleWhenSelected
                }
                titleLabel?.font = UIFont.systemFont(ofSize: size, weight: isSelected ? .semibold : .regular)
            }
        }
    }

    override func updateUIForStateUpdate() {
        super.updateUIForStateUpdate()
        switch style {
        case .selection:
            if isSelected {
                backgroundColor = tintColor
            } else if isHover {
                backgroundColor = Asset.Button.stdHover.color
            } else {
                backgroundColor = Asset.Button.stdBase.color
            }
        case .action:
            if isHover || isHighlighted {
                backgroundColor = Asset.Button.stdHover.color
            } else {
                backgroundColor = Asset.Button.stdBase.color
            }
        default:
            break
        }
    }

    override var canBecomeFocused: Bool { true }
}
