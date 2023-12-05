/*
 BottomAlignTableViewTests.swift
 AppFramework

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

#if canImport(UIKit)
@testable import B9ChatAI
import UIKit
import XCTest

class BottomAlignTableViewTests: XCTestCase {

    override func tearDown() {
        super.tearDown()
        listDataSource = nil
        window = nil
    }

    func testOneRow() {
        let sut = setupViews()

        listDataSource.items = []
        sut.reloadData()

        sut.setNeedsLayout()
        sut.layoutIfNeeded()
        attachment(sut, name: "empty")

        listDataSource.items = ["1"]
        sut.insertRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        noBlockingWait(0)
        sut.setNeedsLayout()
        sut.layoutIfNeeded()
        attachment(sut, name: "add row")
        XCTAssertGreaterThan(sut.contentInset.top, 100)
    }

    func test() {
        let sut = setupViews()

        listDataSource.items = ["1", "2", "3", "4", "5", "6", "7", "8"]
        sut.reloadData()

        sut.setNeedsLayout()
        sut.layoutIfNeeded()
        attachment(sut, name: "init")

        print("Will cell extent...")
        guard let firstCell = sut.cellForRow(at: IndexPath(row: 0, section: 0)) as? TableHeightCell else {
            fatalError()
        }
        firstCell.label.text = "1\n2\n3"
        sut.beginUpdates()
        sut.endUpdates()
        noBlockingWait(0)
        sut.setNeedsLayout()
        sut.layoutIfNeeded()
        attachment(sut, name: "first extented")
    }

    private var window: UIWindow!
    private var listDataSource: DataSource!
}

extension BottomAlignTableViewTests {
    func setupViews() -> BottomAlignTableView {
        let win = UIWindow()
        win.isHidden = false
        win.frame = CGRect(x: 0, y: 0, width: 300, height: 300)

        let sut = BottomAlignTableView(frame: win.bounds)
        sut.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sut.register(UINib(nibName: "TableHeightCell", bundle: Bundle(for: BottomAlignTableViewTests.self)), forCellReuseIdentifier: "Cell")
        let source = DataSource()
        sut.dataSource = source
        listDataSource = source

        win.addSubview(sut)
        window = win
        return sut
    }

    func attachment(_ view: UIView, name: String? = nil, failOnly: Bool = false) {
        let attachment = XCTAttachment(image: view.renderToImage())
        attachment.lifetime = failOnly ? .deleteOnSuccess : .keepAlways
        if let name = name {
            attachment.name = name
        }
        add(attachment)
    }
}

private class DataSource: NSObject, UITableViewDataSource {
    var items = [String]()

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? TableHeightCell else {
            fatalError()
        }
        cell.label.text = items[indexPath.item]
        return cell
    }
}

@objc(TableHeightCell)
private class TableHeightCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
}

#endif
