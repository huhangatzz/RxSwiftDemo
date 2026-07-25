//
//  ViewController.swift
//  RxSwiftDemo
//
//  Created by Kaiser on 2026/7/24.
//

import UIKit
import SnapKit

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    private let cellIdentidif = "CellID"
    
    private struct Demos {
        var title: String
        var content: String
        let makeVC: @MainActor ()->UIViewController
    }
    
    private var demos:[Demos] = [
        Demos(title: "1.输入框操作", content: "解决登录页相关逻辑", makeVC: { SimpleValidationViewController() })
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "RxSwift使用"
        
        let tableView = UITableView(frame: CGRectZero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(listMessageTableViewCell.self, forCellReuseIdentifier: listMessageTableViewCell.CellID)
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: listMessageTableViewCell.CellID, for: indexPath) as! listMessageTableViewCell
        let model = demos[indexPath.row]
        cell.loadData(title: model.title, content: model.content)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = demos[indexPath.row].makeVC()
        navigationController?.pushViewController(vc, animated: true)
    }
}

private class listMessageTableViewCell: UITableViewCell {
    static let CellID = "listMessageTableViewCellID"
    
    let bottomView = UIView()
    let titleLabel = UILabel()
    let contentLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        accessoryType = .disclosureIndicator
        
        configUI()
        layoutUI()
    }
    
    func configUI() {
        bottomView.layer.cornerRadius = 10
        bottomView.clipsToBounds = true
        bottomView.backgroundColor = .cyan
        contentView.addSubview(bottomView)
        
        titleLabel.textAlignment = .left
        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.textColor = .secondaryLabel
        bottomView.addSubview(titleLabel)
        
        contentLabel.textAlignment = .left
        contentLabel.font = .systemFont(ofSize: 14)
        contentLabel.textColor = .placeholderText
        bottomView.addSubview(contentLabel)
    }
    
    func layoutUI() {
        bottomView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview().inset(12)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.bottom.equalToSuperview().inset(12)
        }
    }
    
    func loadData(title: String, content: String) {
        titleLabel.text = title
        contentLabel.text = content
    }
    
    required init?(coder: NSCoder) {
        fatalError("error")
    }
    
    
}

