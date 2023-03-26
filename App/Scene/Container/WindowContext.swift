//
//  WindowContext.swift
//  B9ChatAI
//
//  Created by BB9z on 2023/3/20.
//  Copyright © 2023 B9Software. All rights reserved.
//

import UIKit

#if targetEnvironment(macCatalyst)
extension NSToolbar {
    static func of(_ view: UIView) -> NSToolbar? {
        view.window?.windowScene?.titlebar?.toolbar
    }
}
#endif

extension SceneDelegate {
    static func of(_ view: UIView) -> Self? {
        view.window?.windowScene?.delegate as? Self
    }
}

extension RootViewController {
    static func of(_ view: UIView) -> Self? {
        view.window?.rootViewController as? Self
    }
}

class TestViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction private func onTest(_ sender: UIButton) {
//        sender.isEnabled = false
        if let task = testTask {
            return
        }
        testTask = createTask()
//        testTask = Task {
//            try? await syncWork()
//            sender.isEnabled = true
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//            AppLog().debug("Work cancel")
//            self.testTask?.cancel()
//        }
    }

    func createTask() -> Task<[String], Error> {
        Task {
            AppLog().debug("Task <<<")
            await Task.yield()
            AppLog().debug("Task sleep")
            sleep(10)

            AppLog().debug("Task >>>")

            return ["a", "b"]
        }
    }

    func syncWork() async throws {
        AppLog().debug("Work <<<")
        try? await Task.sleep(nanoseconds: 1000000000)
//        if Task.isCancelled {
//            AppLog().debug("Work got cancel")
//            return
//        }
        try Task.checkCancellation()
        AppLog().debug("Work >>>")
    }

    var testTask: Task<[String], Error>?
}
