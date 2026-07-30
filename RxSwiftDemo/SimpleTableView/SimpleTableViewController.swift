//
//  SimpleTableViewController.swift
//  RxSwiftDemo
//
//  Created by Kaiser on 2026/7/30.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

struct SimpleTableItem {
    let title: String
    let detail: String
    let iconName: String
}

final class SimpleTableViewController: UIViewController {
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.showsVerticalScrollIndicator = true
        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        tableView.register(
            SimpleTableViewCell.self,
            forCellReuseIdentifier: SimpleTableViewCell.reuseIdentifier
        )
        return tableView
    }()

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "自定义 Cell"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.bottom.equalToSuperview()
        }

        let items = (0..<20).map {
            SimpleTableItem(
                title: "第 \($0 + 1) 条数据",
                detail: "这是通过 SimpleTableItem 模型传递给自定义 Cell 的内容",
                iconName: "person.crop.circle"
            )
        }

        Observable.just(items)
            .bind(to: tableView.rx.items(
                cellIdentifier: SimpleTableViewCell.reuseIdentifier,
                cellType: SimpleTableViewCell.self
            )) { _, item, cell in
                cell.configure(with: item)
            }
            .disposed(by: disposeBag)
    }
}
