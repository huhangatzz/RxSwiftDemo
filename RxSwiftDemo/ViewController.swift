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
//        Demos(title: "1.输入框操作", content: "RxSwift 应用程序 - 输入验证", makeVC: { SimpleValidationViewController() }),
//        Demos(title: "2.函数式编程", content: "函数式编程是种编程范式，它需要我们将函数作为参数传递，或者作为返回值返还。我们可以通过组合不同的函数来得到想要的结果。", makeVC: { FucntionProgramViewController() }),
//        Demos(title: "3.Observable - 可监听序列", content: "Observable 可以用于描述元素异步产生的序列", makeVC: { ObservableKnowViewController() }),
//        Demos(title: "4.Signal - 可监听序列", content: "Signal 不会对新观察者回放上一个元素", makeVC: { SignalKnowViewController() }),
//        Demos(title: "5.AnyObserver - 任意观察者", content: "AnyObserver 可以用来描叙任意一种观察者", makeVC: { AnyObserverViewController() }),
//        Demos(title: "6.Subject", content: "4种Subject", makeVC: { SubjectKnowViewController() }),
//        Demos(title: "7.操作符选择", content: "了解操作符", makeVC: { OperatorSelectViewController() }),
//        Demos(title: "8.MVVM简单了解", content: "RxSwift下的MVVM", makeVC: { MVVMKnowViewController() }),
        Demos(title: "9.MVVM注册", content: "复杂的MVVM", makeVC: {
            let sb = UIStoryboard(name: "RegisterViewController", bundle: nil)
            guard let registerVC = sb.instantiateViewController(withIdentifier: "RegisterViewController") as? RegisterViewController else { return UIViewController() }
            return registerVC
        }),
        Demos(title: "10.手机验证码登录", content: "RxSwift 实战登录页面", makeVC: {
            NormalRegisterViewController()
        }),
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
        contentLabel.numberOfLines = 0
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
