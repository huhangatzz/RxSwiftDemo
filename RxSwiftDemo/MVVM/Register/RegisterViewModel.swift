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
    
    //注册按钮是否能点击
    let signupEnabled: Observable<Bool>
    //是否正在登录
    let signingIn: Observable<Bool>
    //登录结果
    let signedIn: Observable<Bool>
    
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
            .do(onNext: { name in//监听打印使用
                   print("输入文本：\(name)")
            })
            .flatMapLatest({ username in
                //内容需要调用接口必须使用flatMapLatest
                validationService.validateUsername(username)// 这里有接口请求后,需要调用observe
                    .observe(on: MainScheduler.instance)// 下游都放到主线程中执行
                    .catchAndReturn(.failed(message: "无法连接服务器")) //收到error时才会执行这样
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
        .share(replay: 1) //共享使用
        
        //是否正在注册中
        let signingIn = ActivityIndicator()
        self.signingIn = signingIn.asObservable()
        
        // 合并两条输入流：用户名、密码
        /*
         combineLatest规则
         1.必须两个流都至少发射过一次值，才开始输出；
         2.任意一条流更新，立刻取出：【用户名最新值 + 密码最新值】组装元组下发；
         3.返回值：Observable<(username: String, password: String)>
         */
        let usernameAndPassword = Observable.combineLatest(input.username,input.password) {
            //返回元组
            (username:$0, password:$1)
        }
        
        //登录结果
        signedIn = input.loginTaps
            .withLatestFrom(usernameAndPassword)//用户点击登录按钮那一刻，拿到此刻输入框最新填写的账号密码
            .flatMapLatest({ pair in //收到上游事件，执行闭包
                API.signup(pair.username, password: pair.password)
                    .observe(on: MainScheduler.instance)
                    .catchAndReturn(false)
                    .trackActivity(signingIn)//是否激活小菊花
            })
            //收到上游事件，执行闭包
            .flatMapLatest({ loggedin -> Observable<Bool> in
                //上面的loginTaps这个被订阅后,整个管道就畅通了
                let message = loggedin ? "Mock: 注册成功" : "Mock: 注册失败"
                return wireframe.promptFor(message, cancelAction: "OK", actions: [])
                    .map { _ in
                        loggedin
                    }
            })
            .share(replay: 1)
        
        /*
         combineLatest 规则回顾
         所有上游流都至少发出过 1 次值，才会产生第一次输出
         任意一条上游产生新值，立刻收集四条流【最新的值】送入闭包计算
         
         监听四项条件的实时变化，任意条件变动，重新计算「注册按钮能不能点击」。
         */
        signupEnabled = Observable.combineLatest(
            validatedUsername,
            validatePassword,
            validatePasswordRepeated,
            signingIn.asObservable()
        ) { username, password, repeatPassword, signingIn in
            username.isValid && password.isValid && repeatPassword.isValid && !signingIn
        }
        .distinctUntilChanged() //两次值不一致才执行
        .share(replay: 1)
        
    }
}
