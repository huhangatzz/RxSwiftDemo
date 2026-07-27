//
//  AnyObserverViewController.swift
//  RxSwiftDemo
//
//  Created by 胡航 on 2026/7/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

private let minimalUsernameLength = 5
private let minimalPasswordLength = 5

class AnyObserverViewController: UIViewController {

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
        //anyObserverDeal()
        binderDeal()
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
    
    //AnyObserver 使用
    func anyObserverDeal() {
        //观察者
        let observer: AnyObserver<Bool> = AnyObserver { [weak self] event in
            switch event {
            case .next(let isHidden):
                self?.nameTipLabel.isHidden = isHidden
            default:
                break
            }
        }
        
        let usernameValid = nameTF.rx.text.orEmpty
            .map { $0.count >= minimalUsernameLength }
            .share(replay: 1)
        usernameValid.bind(to: observer)
            .disposed(by: disposeBag)
    }
    
    //Binder的使用
    func binderDeal() {
        
        let observer: Binder<Bool> = Binder(nameTipLabel) { view, isHidden in
            view.isHidden = isHidden
        }
        
        let usernameValid = nameTF.rx.text.orEmpty
            .map { $0.count >= minimalUsernameLength }
            .share(replay: 1)
        usernameValid.bind(to: observer)
            .disposed(by: disposeBag)
    }
}
