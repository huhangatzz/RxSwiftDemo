//
//  SignalKnowViewController.swift
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

class SignalKnowViewController: UIViewController {

    let bottomView = UIView()
    let nameLabel = UILabel()
    let textField = UITextField()
    let nameSizeLabel = UILabel()
    let button = UIButton(type: .custom)
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createUI()
        layoutUI()
        logicDeal()
        //driverClick()
        signalClick()
    }
    
    func createUI() {
        view.addSubview(bottomView)
        
        nameLabel.text = ""
        nameLabel.font = UIFont.systemFont(ofSize: 15)
        bottomView.addSubview(nameLabel)
        
        textField.backgroundColor = .cyan
        textField.clearButtonMode = .whileEditing
        textField.placeholder = "请输入用户名"
        textField.layer.cornerRadius = 4
        textField.clipsToBounds = true
        textField.leftView = UIView(frame: CGRectMake(0, 0, 10, 44))
        textField.leftViewMode = .always;
        textField.font = UIFont.systemFont(ofSize: 14)
        bottomView.addSubview(textField)
        
        nameSizeLabel.text = ""
        nameSizeLabel.font = UIFont.systemFont(ofSize: 12)
        nameSizeLabel.textColor = .red
        bottomView.addSubview(nameSizeLabel)

        button.backgroundColor = .cyan
        button.setTitle("登录", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        bottomView.addSubview(button)
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
        
        textField.snp.makeConstraints { make in
            make.leading.trailing.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.height.equalTo(44)
        }
        
        nameSizeLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(nameLabel)
            make.top.equalTo(textField.snp.bottom).offset(4)
            make.height.equalTo(nameLabel)
        }

        button.snp.makeConstraints { make in
            make.leading.trailing.equalTo(nameLabel)
            make.top.equalTo(nameSizeLabel.snp.bottom).offset(20)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().inset(12)
        }
    }
    
    //Driver 会对新观察者回放（重新发送）上一个元素
    func logicDeal() {
        
        /*
         这个例子只是将用户输入的姓名绑定到对应的标签上。当用户输入姓名后，我们创建了一个新的观察者，用于订阅姓名的字数。那么问题来了，订阅时，展示字数的标签会立即更新吗？

         嗯、、、 因为 Driver 会对新观察者回放上一个元素（当前姓名），所以这里是会更新的。在对他进行订阅时，标签的默认文本会被刷新。这是合理的。
         */
        
        let state: Driver<String?> = textField.rx.text.asDriver()
        
        let observe = nameLabel.rx.text
        let _ = state.drive(observe)
        
        //假设以下代码是在用户输入姓名后运行
        let newOberver = nameSizeLabel.rx.text
        let _ = state.map { $0?.count.description }.drive(newOberver)
    }
    
    //如果我们用 Driver 来描述点击事件呢，这样合理吗？
    func driverClick() {
        
        /*
         当用户点击一个按钮后，我们创建一个新的观察者，来响应点击事件。此时会发生什么？Driver 会把上一次的点击事件回放给新观察者。所以，这里的 newObserver 在订阅时，就会接受到上次的点击事件，然后弹出提示框。这似乎不太合理
         */
        
        let disposeBag = DisposeBag()
            
        // BehaviorRelay 可以转为 Driver，持有当前状态
        let relay = BehaviorRelay<String>(value: "初始值")
        let driver = relay.asDriver()
        
        // 订阅A
        driver.drive(onNext: { str in
            print("[订阅A] 收到：\(str)")
        }).disposed(by: disposeBag)
        
        print("👉 更新状态：Message_1")
        relay.accept("Message_1")
        
        print("✅ 新增订阅者B")
        // B刚订阅，立刻获得最新状态 Message_1
        driver.drive(onNext: { str in
            print("[订阅B] 收到：\(str)")
        }).disposed(by: disposeBag)
        
        print("👉 更新状态：Message_2")
        relay.accept("Message_2")
    }
    
    //Signal
    func signalClick() {
        
        let disposeBag = DisposeBag()
            
            // PublishRelay 行为等价 Signal：不缓存事件
            let source = PublishRelay<String>()
            
            // 第1个订阅者
            source.subscribe(onNext: { str in
                print("[订阅A] 收到：\(str)")
            }).disposed(by: disposeBag)
            
            print("👉 发出事件：Message_1")
            source.accept("Message_1")
            
            // 【重点】事件发出之后，才新增订阅者B
            print("✅ 新增订阅者B")
            source.subscribe(onNext: { str in
                print("[订阅B] 收到：\(str)")
            }).disposed(by: disposeBag)
            
            print("👉 发出事件：Message_2")
            source.accept("Message_2")
    }
}
