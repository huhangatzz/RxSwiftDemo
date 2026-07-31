//
//  MoyaNetworkService.swift
//  RxSwiftDemo
//
//  Created by Kaiser on 2026/7/31.
//

import Foundation
import Moya
import Alamofire

//Moya接口封装
enum MoyaNetworkService {
    case sendVerificationCode(phone: String, type: String)
    case login(data: LoginRequestParam)
}

extension MoyaNetworkService: TargetType {
    var baseURL: URL {
        return URL(string: "http://8.137.116.86:8092")!
    }
    
    var path: String {
        switch self {
        case .sendVerificationCode:
            return "/send"
        case .login:
            return "/home/app/login"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .sendVerificationCode, .login:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case let .sendVerificationCode(phone, type):
            return .requestParameters(
                parameters: [
                    "phone": phone,
                    "type": type
                ],
                encoding: JSONEncoding.default
            )
        case let .login(data):
            return .requestJSONEncodable(data)
        }
    }
    
    var headers: [String : String]? {
        [
            "Content-Type": "application/json",
            "User-Agent": "zhikon/1.3.22 (iPhone; iOS 26.5.2; Scale/3.00)",
            "Accept-Language": "zh-Hans-CN;q=1",
            "Accept": "*/*",
            "deviceCode": "",
            "Accept-Encoding": "gzip, deflate"
        ]
    }
}
