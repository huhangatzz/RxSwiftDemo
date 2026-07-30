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
    private let pageSize = 20
    private let maxPage = 3
    private var currentPage = 0
    //始终保存当前最新值。可以通过 .value 获取当前数组。可以通过 .accept() 修改数据。不会发出 error 或 completed，适合保存页面 UI 状态。新订阅者会立即收到当前最新数据。
    private let itemsRelay = BehaviorRelay<[SimpleTableItem]>(value: [])

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.showsVerticalScrollIndicator = true
        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        tableView.register(SimpleTableViewCell.self, forCellReuseIdentifier: SimpleTableViewCell.reuseIdentifier
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

        bindTableView()
        configureRefresh()
        tableView.beginRefreshing()
    }

    private func bindTableView() {
        itemsRelay
            .bind(to: tableView.rx.items(
                cellIdentifier: SimpleTableViewCell.reuseIdentifier,
                cellType: SimpleTableViewCell.self)
            ) { _, item, cell in
                cell.configure(with: item)
            }
            .disposed(by: disposeBag)
    }

    private func configureRefresh() {
        tableView.configureRefresh(
            onRefresh: { [weak self] in
                self?.loadData(isRefresh: true)
            },
            onLoadMore: { [weak self] in
                self?.loadData(isRefresh: false)
            }
        )
    }

    private func loadData(isRefresh: Bool) {
        let targetPage = isRefresh ? 1 : currentPage + 1

        // 模拟分页网络请求。
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            guard let self else { return }

            let newItems = self.makeItems(page: targetPage)
            //使用self.itemsRelay.value获取当前的数据
            let allItems = isRefresh ? newItems : self.itemsRelay.value + newItems

            if !newItems.isEmpty {
                self.currentPage = targetPage
            }

            //使用self.itemsRelay.accept修改当前的数据,修改后立即会刷新UI
            self.itemsRelay.accept(allItems)
            self.tableView.endRefreshing(hasMoreData: !newItems.isEmpty)
        }
    }

    private func makeItems(page: Int) -> [SimpleTableItem] {
        guard page <= maxPage else { return [] }

        let startIndex = (page - 1) * pageSize
        return (startIndex..<(startIndex + pageSize)).map {
            SimpleTableItem(
                title: "第 \($0 + 1) 条数据",
                detail: "这是通过 SimpleTableItem 模型传递给自定义 Cell 的内容",
                iconName: "person.crop.circle"
            )
        }
    }
}
