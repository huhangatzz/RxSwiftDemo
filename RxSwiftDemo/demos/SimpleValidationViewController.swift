//
//  SimpleValidationViewController.swift
//  RxSwiftDemo
//
//  Created by Kaiser on 2026/7/24.
//

import UIKit
import SnapKit

class SimpleValidationViewController: ScrollDemoViewController {

    private let nameTextField = UITextField.demoTextField("输入用户名")
    private let pwdTextField = UITextField.demoTextField("输入密码")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let cardSection = addSection("")
    
        let nameLabel = UILabel.demoLabel("用户名", font: .boldSystemFont(ofSize: 17))
        let nameValidLabel = UILabel.demoLabel("需要输入5位有效数字", font: .boldSystemFont(ofSize: 12), color: .red)
        sectionStack(in: cardSection).addArrangedSubview(nameLabel)
        sectionStack(in: cardSection).addArrangedSubview(nameTextField)
        sectionStack(in: cardSection).addArrangedSubview(nameValidLabel)
        
        let pwdLabel = UILabel.demoLabel("密码", font: .boldSystemFont(ofSize: 17))
        let pwdValidLabel = UILabel.demoLabel("需要输入5位有效数字", font: .boldSystemFont(ofSize: 12), color: .red)
        sectionStack(in: cardSection).addArrangedSubview(pwdLabel)
        sectionStack(in: cardSection).addArrangedSubview(pwdTextField)
        sectionStack(in: cardSection).addArrangedSubview(pwdValidLabel)
        
        let button = UIButton(type: .system)
        button.backgroundColor = .blue.withAlphaComponent(0.5)
        button.setTitle("登录", for: .normal)
        button.setTitleColor(.cyan, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 17)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        sectionStack(in: cardSection).addArrangedSubview(button)
    }
    
    
}
