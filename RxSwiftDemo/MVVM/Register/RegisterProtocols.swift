//
//  RegisterProtocols.swift
//  RxSwiftDemo
//
//  Created by Kaiser on 2026/7/28.
//

import Foundation
import RxSwift

// 验证结果
enum ValidationResult {
    case ok(message: String)
    case empty
    case validating
    case failed(message: String)
}

// 提供 GitHub 网络服务
protocol GithubAPI {
    func usernameValilable(_ username: String) -> Observable<Bool>
}

// 提供输入验证服务
protocol GitHubValidationService {
    func validateUsername(_ username: String) -> Observable<ValidationResult>
}
