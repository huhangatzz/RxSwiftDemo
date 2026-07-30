//
//  SectionTableViewController.swift
//  RxSwiftDemo
//
//  Created by 胡航 on 2026/7/30.
//

import UIKit
import SnapKit

private struct TableSection {
    let title: String
    let items: [String]
}

private final class SectionHeaderView: UITableViewHeaderFooterView {
    static let reuseIdentifier = "SectionHeaderView"

    private let titleLabel = UILabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        contentView.backgroundColor = .secondarySystemBackground
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label
        contentView.addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String) {
        titleLabel.text = title
    }
}

final class SectionTableViewController: UIViewController {
    private let sections = [
        TableSection(title: "水果", items: ["苹果", "香蕉", "橙子"]),
        TableSection(title: "蔬菜", items: ["番茄", "土豆", "胡萝卜"]),
        TableSection(title: "饮品", items: ["咖啡", "牛奶", "果汁"])
    ]

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.showsVerticalScrollIndicator = true
        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "SectionCell"
        )
        tableView.register(
            SectionHeaderView.self,
            forHeaderFooterViewReuseIdentifier: SectionHeaderView.reuseIdentifier
        )
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "分区列表"
        view.backgroundColor = .systemBackground

        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension SectionTableViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].items.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "SectionCell",
            for: indexPath
        )
        cell.textLabel?.text = sections[indexPath.section].items[indexPath.row]
        return cell
    }
}

extension SectionTableViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: SectionHeaderView.reuseIdentifier
        ) as? SectionHeaderView
        header?.configure(title: sections[section].title)
        return header
    }

    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        44
    }
}
