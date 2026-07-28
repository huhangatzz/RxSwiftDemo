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

    let API: GithubAPI
    
    static let shareValidationService = GitHubDefaultValidationService(API: GitHubDefaultAPI.sharedAPI)
    
    init(API: GithubAPI) {
        self.API = API
    }
    
    // 用户名的各种逻辑判断放在这里面了
    func validateUsername(_ username: String) -> Observable<ValidationResult> {
        
        if username.isEmpty {
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
}
