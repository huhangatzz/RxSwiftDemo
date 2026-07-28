//
//  RegisterViewController.swift
//  RxSwiftDemo
//
//  Created by Kaiser on 2026/7/27.
//

import UIKit
import RxSwift
import RxCocoa

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
            dependency: (
                API: GitHubDefaultAPI.sharedAPI,
                validationService: GitHubDefaultValidationService.shareValidationService,
                wireframe: DefaultWireframe.shared
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
        
    }
   
}
