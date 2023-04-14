//
//  SchemeViewController.swift
//  SchemePlayground
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import B9Action
import UIKit

class SchemeViewController:
    UIViewController,
    UITextViewDelegate
{

    let appScheme = "b9chatai"

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        needsUpdateURL.set()
    }

    @IBOutlet private weak var commandSegment: UISegmentedControl!
    @IBOutlet private weak var idField: UITextField!
    @IBOutlet private weak var contentField: UITextView!

    @IBOutlet private weak var jsBookmarkField: UITextField!
    @IBOutlet private weak var resultURLField: UITextField!
    private lazy var needsUpdateURL = DelayAction(Action(target: self, selector: #selector(updateURL)), delay: 0.2)

    @IBAction private func onCommandChanged(_ sender: Any) {
        needsUpdateURL.set()
    }

    @IBAction private func onCopyJS(_ sender: Any) {
        UIPasteboard.general.string = jsBookmarkField.text
    }

    @IBAction private func onCopy(_ sender: Any) {
        UIPasteboard.general.string = resultURLField.text
    }

    @IBAction private func onCall(_ sender: Any) {
        guard let str = resultURLField.text,
            let url = URL(string: str) else {
            alert(message: "The content in the input box is not a legal URL.")
            return
        }
        if url.scheme != appScheme {
            alert(message: "The URL in the input box is not a B9ChatAI URL.")
            return
        }
        UIApplication.shared.open(url)
    }

    private func alert(message: String) {
        let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension SchemeViewController {
    @objc private func updateURL() {
        var comp = URLComponents()
        comp.scheme = appScheme
        comp.host = commandSegment.titleForSegment(at: commandSegment.selectedSegmentIndex) ?? "?"
        var queries = [URLQueryItem]()
        if let value = idField.text?.trimmed() {
            queries.append(.init(name: "id", value: value))
        }
        if let value = contentField.text?.trimmed() {
            queries.append(.init(name: "text", value: value))
        }
        comp.queryItems = queries
        resultURLField.text = comp.url?.absoluteString

        queries.append(.init(name: "text", value: ""))
        comp.queryItems = queries
        let urlPart = comp.url?.absoluteString ?? "🐞"
        jsBookmarkField.text = "javascript:a=\"\(urlPart)\"+encodeURIComponent(window.getSelection().toString());window.location.href=a"
    }

    @IBAction private func onTextFieldsChanged(_ sender: Any) {
        needsUpdateURL.set()
    }

    func textViewDidChange(_ textView: UITextView) {
        needsUpdateURL.set()
    }
}
