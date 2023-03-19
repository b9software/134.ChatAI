//
//  WindowContext.swift
//  B9ChatAI
//
//  Created by BB9z on 2023/3/20.
//  Copyright © 2023 B9Software. All rights reserved.
//

import UIKit

extension NSToolbar {
    static func of(_ view: UIView) -> NSToolbar? {
        view.window?.windowScene?.titlebar?.toolbar
    }
}

extension SceneDelegate {
    static func of(_ view: UIView) -> SceneDelegate? {
        view.window?.windowScene?.delegate as? SceneDelegate
    }
}

class TestViewController: UIViewController {
    @IBOutlet private weak var aSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        aSwitch.preferredStyle = .checkbox
    }
}

// https://stackoverflow.com/questions/62321540/drag-and-drop-catalyst
class TestView: UIView, UIDropInteractionDelegate {
    override func awakeFromNib() {
        super.awakeFromNib()
        let dropInteraction = UIDropInteraction(delegate: self)
        addInteraction(dropInteraction)
    }

    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        // Ensure the drop session has an object of the appropriate type
//        return session.canLoadObjects(ofClass: UIImage.self)
        return true
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }

    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        // Consume drag items (in this example, of type UIImage).
        session.loadObjects(ofClass: UIImage.self) { imageItems in
            AppLog().debug("DD> load image: \(imageItems)")
        }
        session.loadObjects(ofClass: String.self) { item in
            AppLog().debug("DD> load string: \(item)")
        }
        session.loadObjects(ofClass: URL.self) { item in
            AppLog().debug("DD> load url: \(item)")
        }
        // Perform additional UI updates as needed.
    }
}
