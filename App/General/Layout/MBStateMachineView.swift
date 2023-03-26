/*
 MBStateMachineView

 Copyright © 2018, 2023 BB9z.
 Copyright © 2015 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import B9MulticastDelegate
import UIKit

// @MBDependency:2
/**
 划定一个区域，改变一个标识符，这块区域将显示不同的内容，这就是状态机 view 的作用

 frame 现在是固定的
 */
class MBStateMachineView: UIView {
    weak var viewSource: AnyObject?
    weak var contentView: UIView?
    weak var delegate: MBStateMachineViewDelegate?
    var state: String? {
        didSet {
            stateChanged(from: oldValue, to: state)
        }
    }

    private let delegates = MulticastDelegate<MBStateMachineViewDelegate>()

    override func awakeFromNib() {
        super.awakeFromNib()
        if viewSource != nil { return }
        for subView in subviews {
            if let identifyingView = subView as? MBStateMachineViewIdentifying,
               let stateIdentifier = identifyingView.stateIdentifier {
                identifyingView.isHidden = state != stateIdentifier
            }
        }
    }

    private func view(for state: String) -> UIView? {
        if let source = viewSource {
            let key = "viewFor\(state)"
            if let result = source.value?(forKey: key) as? UIView {
                return result
            }
        }
        return subviews.first {
            ($0 as? MBStateMachineViewIdentifying)?.stateIdentifier == state
        }
    }

    private func stateChanged(from oldState: String?, to newState: String?) {
        if let newState = newState,
           oldState != newState {
            let oldView = contentView
            let newView = view(for: newState)

            if oldView != newView {
                if viewSource != nil {
                    oldView?.removeFromSuperview()
                    if let view = newView {
                        addSubview(view, resizeOption: .fill)
                        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    }
                } else {
                    oldView?.isHidden = true
                    if let view = newView as? MBStateMachineViewIdentifying,
                       view.dontResizeWhenStateChanged {
                        // noop
                    } else {
                        newView?.frame = bounds
                    }
                    newView?.isHidden = false
                }
                contentView = newView
            }
        }
        isHidden = newState == nil
        delegates.invoke {
            $0.stateMachineView(self, didChangedStateFromState: oldState, toState: newState)
        }
    }
}

protocol MBStateMachineViewDelegate: AnyObject {
    func stateMachineView(_ view: MBStateMachineView, didChangedStateFromState oldStats: String?, toState newState: String?)
}

protocol MBStateMachineViewIdentifying: UIView {
    var stateIdentifier: String? { get }
    var dontResizeWhenStateChanged: Bool { get }
}

class MBStateMachineSubview: UIView, MBStateMachineViewIdentifying {
    @IBInspectable var stateIdentifier: String?
    @IBInspectable var dontResizeWhenStateChanged: Bool = false
}
