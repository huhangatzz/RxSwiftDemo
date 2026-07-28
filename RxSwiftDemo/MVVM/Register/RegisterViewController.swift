//
//  RegisterViewController.swift
//  RxSwiftDemo
//
//  Created by Kaiser on 2026/7/27.
//

import UIKit
import RxSwift
import RxCocoa

//控制器仅仅只做数据绑定操作,其他逻辑全部都在ViewModel中
class RegisterViewController: UIViewController {
    @IBOutlet var usernameOutlet: UITextField!
    @IBOutlet var usernameValidationOutlet: UILabel!

    @IBOutlet var passwordOutlet: UITextField!
    @IBOutlet var passwordValidationOutlet: UILabel!

    @IBOutlet var repeatedPasswordOutlet: UITextField!
    @IBOutlet var repeatedPasswordValidationOutlet: UILabel!

    @IBOutlet var signupOutlet: UIButton!
    @IBOutlet var signingUpOulet: UIActivityIndicatorView!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //初始化viewModel
        let viewModel = RegisterViewModel(
            input: (
                username: usernameOutlet.rx.text.orEmpty.asObservable(),
                password: passwordOutlet.rx.text.orEmpty.asObservable(),
                repeatedPasswrod: repeatedPasswordOutlet.rx.text.orEmpty.asObservable(),
                loginTaps: signupOutlet.rx.tap.asObservable()
            ),
            dependency: (//依赖
                API: GitHubDefaultAPI.sharedAPI,//接口请求工具类
                validationService: GitHubDefaultValidationService.shareValidationService,//逻辑类
                wireframe: DefaultWireframe.shared//系统弹窗类
            ),
        )
        
        viewModel.validatedUsername
            .bind(to: usernameValidationOutlet.rx.validationResult)
            .disposed(by: disposeBag)
        
        viewModel.validatePassword
            .bind(to: passwordValidationOutlet.rx.validationResult)
            .disposed(by: disposeBag)
        
        viewModel.validatePasswordRepeated
            .bind(to: repeatedPasswordValidationOutlet.rx.validationResult)
            .disposed(by: disposeBag)
        
        viewModel.signingIn
            .bind(to: signingUpOulet.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.signedIn
            .subscribe { signedIn in
                print("User signed in \(signedIn)")
            }
            .disposed(by: disposeBag)
        
        viewModel.signupEnabled
            .subscribe { [weak self] valid in
                self?.signupOutlet.isEnabled = valid
                self?.signupOutlet.alpha = valid ? 1.0 : 0.5
            }
            .disposed(by: disposeBag)
        
        //点击事件
        let tagBackground = UITapGestureRecognizer()
        tagBackground.rx.event
            .subscribe { [weak self] _ in
                self?.view.endEditing(true)
            }
            .disposed(by: disposeBag)
        view.addGestureRecognizer(tagBackground)
    }
   
}
