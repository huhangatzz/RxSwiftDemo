//
//  GitHubDefaultValidationService.swift
//  RxSwiftDemo
//
//  Created by Kaiser on 2026/7/28.
//

import UIKit
import RxSwift
import RxCocoa

class GitHubDefaultValidationService: GitHubValidationService {
    //这块代码直接使用shareValidationService类方法完成初始化
    let API: GithubAPI
    
    //传递真正的网络请求工具GitHubDefaultAPI
    static let shareValidationService = GitHubDefaultValidationService(API: GitHubDefaultAPI.sharedAPI)
    
    init(API: GithubAPI) {
        self.API = API
    }
    
    let minPasswordCount = 5
    
    // 用户名的各种逻辑判断放在这里面了
    func validateUsername(_ username: String) -> Observable<ValidationResult> {
        
        //用户名是为空
        if username.isEmpty {
            //just 创建 Observable 发出唯一的一个元素
            return .just(.empty)
        }
        
        if username.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil {
            return .just(.failed(message: "用户名只能包含数字或字母"))
        }
        
        let loadingValue = ValidationResult.validating
        
        return API
            .usernameValilable(username)
            .map { available in
                if available {
                    ValidationResult.ok(message: "用户名可用")
                } else {
                    ValidationResult.failed(message: "用户名已经被占用")
                }
            }
            .startWith(loadingValue)
    }
    
    //密码逻辑判断
    func validatePassword(_ password: String) -> ValidationResult {
        let numberOfCharacters = password.count
        
        //字符为空
        if numberOfCharacters == 0 {
            return .empty
        }
        
        //字符位数少于5位
        if numberOfCharacters < minPasswordCount {
            return .failed(message: "密码至少\(minPasswordCount)位字符")
        }
        
        //成功
        return .ok(message: "密码可接受")
    }
    
    // 确认密码校验
    func validateRepeatedPassword(_ password: String, repeatedPassword: String) -> ValidationResult {
        
        if repeatedPassword.count == 0 {
            return .empty
        }
        
        if repeatedPassword == password {
            return .ok(message: "密码相同")
        } else {
            return .failed(message: "密码不同")
        }
    }
}

//网络请求工具类封装
class GitHubDefaultAPI: GithubAPI {
    let URLSession: Foundation.URLSession
    
    static let sharedAPI = GitHubDefaultAPI(URLSession: Foundation.URLSession.shared)
    
    init(URLSession: Foundation.URLSession) {
        self.URLSession = URLSession
    }
    
    //用户名校验接口
    func usernameValilable(_ username: String) -> Observable<Bool> {
        let url = URL(string: "https://github.com/\(username.URLScaped)")!
        let request = URLRequest(url: url)
        return URLSession.rx.response(request: request)
            .map { pair in
                pair.response.statusCode == 404
            }
            .catchAndReturn(false)
    }
    
    //注册
    func signup(_ username: String, password: String) -> Observable<Bool> {
        let signupResult = arc4random() % 5 == 0 ? false : true
        
        return Observable.just(signupResult)
            .delay(.seconds(1), scheduler: MainScheduler.instance)
    }
}
