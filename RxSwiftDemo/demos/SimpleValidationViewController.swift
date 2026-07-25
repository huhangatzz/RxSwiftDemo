//
//  SimpleValidationViewController.swift
//  RxSwiftDemo
//
//  Created by Kaiser on 2026/7/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

private let minimalUsernameLength = 5
private let minimalPasswordLength = 5

class SimpleValidationViewController: UIViewController {

    let bottomView = UIView()
    let nameLabel = UILabel()
    let nameTF = UITextField()
    let nameTipLabel = UILabel()
    let pwdLabel = UILabel()
    let pwdTF = UITextField()
    let pwdTipLabel = UILabel()
    let button = UIButton(type: .custom)
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createUI()
        layoutUI()
        logicDeal()
    }
    
    func createUI() {
        view.addSubview(bottomView)
        
        nameLabel.text = "用户名"
        nameLabel.font = UIFont.systemFont(ofSize: 15)
        bottomView.addSubview(nameLabel)
        
        nameTF.backgroundColor = .cyan
        nameTF.clearButtonMode = .whileEditing
        nameTF.placeholder = "请输入用户名"
        nameTF.layer.cornerRadius = 4
        nameTF.clipsToBounds = true
        nameTF.leftView = UIView(frame: CGRectMake(0, 0, 10, 44))
        nameTF.leftViewMode = .always;
        nameTF.font = UIFont.systemFont(ofSize: 14)
        bottomView.addSubview(nameTF)
        
        nameTipLabel.text = "用户名最少输入\(minimalUsernameLength)"
        nameTipLabel.font = UIFont.systemFont(ofSize: 12)
        nameTipLabel.textColor = .red
        bottomView.addSubview(nameTipLabel)
        
        pwdLabel.text = "密码"
        pwdLabel.font = UIFont.systemFont(ofSize: 15)
        bottomView.addSubview(pwdLabel)
        
        pwdTF.backgroundColor = .cyan
        pwdTF.clearButtonMode = .whileEditing
        pwdTF.placeholder = "请输入密码"
        pwdTF.layer.cornerRadius = 4
        pwdTF.clipsToBounds = true
        pwdTF.leftView = UIView(frame: CGRectMake(0, 0, 10, 44))
        pwdTF.leftViewMode = .always;
        pwdTF.font = UIFont.systemFont(ofSize: 14)
        bottomView.addSubview(pwdTF)
        
        pwdTipLabel.text = "密码最少输入\(minimalPasswordLength)"
        pwdTipLabel.font = UIFont.systemFont(ofSize: 12)
        pwdTipLabel.textColor = .red
        bottomView.addSubview(pwdTipLabel)
        
        button.backgroundColor = .cyan
        button.setTitle("登录", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        bottomView.addSubview(button)
        
        // 点击绿色按钮 -> 弹出提示框
        button.rx.tap.subscribe { [weak self] _ in
            self?.showAlert()
        }.disposed(by: disposeBag)
    }
    
    func showAlert() {
        nameTF.resignFirstResponder()
        pwdTF.resignFirstResponder()
        
        let alert = UIAlertController(title: "提示", message: "可以登录了:\n用户名\(self.nameTF.text ?? ""),\n 密码:\(self.pwdTF.text ?? "")",preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alert, animated: true)
    }
    
    func layoutUI() {
        bottomView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.top.equalToSuperview().offset(12)
            make.height.equalTo(20)
        }
        
        nameTF.snp.makeConstraints { make in
            make.leading.trailing.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.height.equalTo(44)
        }
        
        nameTipLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(nameLabel)
            make.top.equalTo(nameTF.snp.bottom).offset(4)
            make.height.equalTo(nameLabel)
        }
        
        pwdLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.top.equalTo(nameTipLabel.snp.bottom).offset(4)
            make.height.equalTo(nameLabel)
        }
        
        pwdTF.snp.makeConstraints { make in
            make.leading.trailing.equalTo(nameLabel)
            make.top.equalTo(pwdLabel.snp.bottom).offset(8)
            make.height.equalTo(nameTF)
        }
        
        pwdTipLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(nameLabel)
            make.top.equalTo(pwdTF.snp.bottom).offset(4)
            make.height.equalTo(pwdLabel)
        }
        
        button.snp.makeConstraints { make in
            make.leading.trailing.equalTo(nameLabel)
            make.top.equalTo(pwdTipLabel.snp.bottom).offset(20)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().inset(12)
        }
    }
    
    //逻辑处理
    func logicDeal() {
        //用户名是否有效
        let usernameValid = nameTF.rx.text.orEmpty
            // 用户名 -> 用户名是否有效
            .map { $0.count >= minimalUsernameLength }
            .share(replay: 1)
    
        // 用户名是否有效 -> 密码输入框是否可用
        usernameValid.bind(to: pwdTF.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // 用户名是否有效 -> 用户名提示语是否隐藏
        usernameValid.bind(to: nameTipLabel.rx.isHidden).disposed(by: disposeBag)
        
        
        //密码是否有效
        let passwrodValid = pwdTF.rx.text.orEmpty
            .map { $0.count >= minimalPasswordLength }
            .share(replay: 1)
        
        // 密码是否有效 -> 密码提示语是否隐藏
        passwrodValid.bind(to: pwdTipLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        // 所有输入是否有效
        let everthingValid = Observable.combineLatest(usernameValid, passwrodValid) { $0 && $1}
            .share(replay: 1)
        
        // 所有输入是否有效 -> 绿色按钮是否可点击
        everthingValid.bind(to: button.rx.isEnabled)
            .disposed(by: disposeBag)
    }
}
