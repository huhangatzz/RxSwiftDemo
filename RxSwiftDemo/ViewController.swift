//
//  ViewController.swift
//  RxSwiftDemo
//
//  Created by Kaiser on 2026/7/24.
//

import UIKit

class ViewController: UITableViewController {
    private let cellIdentifier = "DemoCell"
    
    private struct Demo {
        let title: String
        let subtitle: String
        let makeViewController: @MainActor () -> UIViewController
    }
    
    private let demos: [Demo] = [
        Demo(title: "1. 输入框使用", subtitle: "数据绑定", makeViewController: { SimpleValidationViewController() }),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
    
        title = "SnapKit 完整示例"
        tableView.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.rowHeight = 68
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let demo = demos[indexPath.row]
        var configuration = cell.defaultContentConfiguration()
        configuration.text = demo.title
        configuration.secondaryText = demo.subtitle
        configuration.secondaryTextProperties.color = .secondaryLabel
        cell.contentConfiguration = configuration
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        navigationController?.pushViewController(demos[indexPath.row].makeViewController(), animated: true)
    }
}

