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
    let validatePassword: Observable<ValidationResult>
    // 确认密码校验结果
    let validatePasswordRepeated: Observable<ValidationResult>
    //注册按钮是否等点击
    
    //是否正在登录
    let signingIn: Observable<Bool>
    
    //登录结果
    //let signedIn: Observable<Bool>
    
    // 输入 -> 输出
    init(
        input:(// 输入
            username: Observable<String>, // 输入的用户名
            password: Observable<String>, //输入的密码
            repeatedPasswrod: Observable<String>, //确认密码
            loginTaps: Observable<Void>
        ),
        dependency: (// 服务
            API: GithubAPI,
            validationService: GitHubValidationService,
            wireframe: Wireframe
        )
    ) {
        let API = dependency.API
        let validationService = dependency.validationService
        let wireframe = dependency.wireframe
        
        //在外界没有订阅之前,validatedUsername就是一个冷信号,所以外界需要调用bind订阅信号
        validatedUsername = input.username
            .do(onNext: { name in
                   print("输入文本：\(name)")
            })
            .flatMapLatest({ username in
                //内容需要调用接口必须使用flatMapLatest
                validationService.validateUsername(username)// 这里有接口请求后,需要调用observe
                    .observe(on: MainScheduler.instance)// 下游都放到主线程中执行
                    .catchAndReturn(.failed(message: "无法连接服务器"))
            })
            .share(replay: 1)//优化性能的
        
        validatePassword = input.password
            //map闭包返回 普通数据（String/Bool/ 结构体）
            //map主要的作用:只做值转换
            .map({ password in
                //string -> ValidationResult
                validationService.validatePassword(password)
            })
            .share(replay: 1)
        
        //combineLatest任意一个上游数据流发出新值时，取出两条流【各自最新的值】，丢给闭包处理
        validatePasswordRepeated = Observable.combineLatest(
            input.password,
            input.repeatedPasswrod
        ) { password, repeatedPassword in
            validationService.validateRepeatedPassword(password, repeatedPassword: repeatedPassword)
        }
        .share(replay: 1)
        
        //是否正在注册中
        let signingIn = ActivityIndicator()
        self.signingIn = signingIn.asObservable()
        
//        let usernameAndPassword = Observable.combineLatest(input.username,input.password) {
//            (username:$0, password:$1)
//        }
        
        //登录结果
//        signedIn = input.loginTaps
//            .withLatestFrom(usernameAndPassword)
//            .flatMapLatest({ pair in
//                API.signup(pair.username, password: pair.password)
//                    .observe(on: MainScheduler.instance)
//                    .catchAndReturn(false)
//                    .trackActivity(signingIn)
//            })
//            .flatMapLatest({ loggedin -> Observable<Bool> in
//                let message = loggedin ? "Mock: 注册成功" : "Mock: 注册失败"
//                return wireframe.promptFor(message, cancelAction: "OK", actions: [])
//                    .map { _ in
//                        loggedin
//                    }
//            })
//            .share(replay: 1)
        
    }
    
    
    
    
}
