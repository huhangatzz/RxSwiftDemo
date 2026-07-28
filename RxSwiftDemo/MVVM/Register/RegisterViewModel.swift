//
//  RegisterViewModel.swift
//  RxSwiftDemo
//
//  Created by Kaiser on 2026/7/27.
//

import Foundation
import RxCocoa
import RxSwift

class RegisterViewModel {
    
    // 输出
    
    // 用户名校验结果
    let validatedUsername: Observable<ValidationResult>
    // 密码校验结果
    //let validatePassword: Observable<ValidationResult>
    
    // 输入 -> 输出
    init(
        input:(// 输入
            username: Observable<String>, // 输入的用户名
            password: Observable<String> //输入的密码
        ),
        dependency: (// 服务
            API: GithubAPI,
            validationService: GitHubValidationService
        )
    ) {
        let API = dependency.API
        let validationService = dependency.validationService
        
        validatedUsername = input.username
            .flatMapLatest({ username in
                validationService.validateUsername(username)
                    .observe(on: MainScheduler.instance)
                    .catchAndReturn(.failed(message: "无法连接服务器"))
            })
            .share(replay: 1)
    }
    
}
