//
//  LoginTestViewController.swift
//  RxSwiftDemo
//
//  Created by Kaiser on 2026/7/31.
//

import UIKit

class LoginTestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        Task {
            do {
                let param = LoginRequestParam(phone: "18083469721", code: "2431")
                let _ = try await MoyaNetworkManager.shared.login(data: param)
            } catch {
                print("Error converting HTML to AttributedString: \(error)")
            }
        }
    }
    
}
