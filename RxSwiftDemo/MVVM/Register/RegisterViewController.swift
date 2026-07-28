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

        let viewModel = RegisterViewModel(
            input: (
                username: usernameOutlet.rx.text.orEmpty.asObservable(),
                password:passwordOutlet.rx.text.orEmpty.asObservable()
            ),
            dependency: (
                API: GitHubDefaultAPI.sharedAPI,
                validationService: GitHubDefaultValidationService.shareValidationService,
            ),
        )
        
        viewModel.validatedUsername
            .bind(to: usernameValidationOutlet.rx.validationResult)
            .disposed(by: disposeBag)
    }
   
}
