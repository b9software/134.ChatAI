//
//  ArticleListDisplayer.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import HasItem
import UIKit

struct Article {
    let title: String
    let link: String
}

class ArticleListDisplayer: UITableViewController {
    var listDataSource = MBTableViewArrayDataSource<Article>()

    override func viewDidLoad() {
        super.viewDidLoad()
        listDataSource.tableView = tableView
        tableView.dataSource = listDataSource
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = listDataSource.item(at: indexPath),
           let url = URL(string: item.link) {
            UIApplication.shared.open(url)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

class ArticleListCell: UITableViewCell, HasItem {
    var item: Article! {
        didSet {
            titleLabel.text = item.title
        }
    }

    @IBOutlet private weak var titleLabel: UILabel!
}
