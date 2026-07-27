//
//  RegisterViewController.swift
//  RxSwiftDemo
//
//  Created by Kaiser on 2026/7/27.
//

import UIKit

class RegisterViewController: UIViewController {
    @IBOutlet var usernameOutlet: UITextField!
    @IBOutlet var usernameValidationOutlet: UILabel!

    @IBOutlet var passwordOutlet: UITextField!
    @IBOutlet var passwordValidationOutlet: UILabel!

    @IBOutlet var repeatedPasswordOutlet: UITextField!
    @IBOutlet var repeatedPasswordValidationOutlet: UILabel!

    @IBOutlet var signupOutlet: UIButton!
    @IBOutlet var signingUpOulet: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }
   
}
