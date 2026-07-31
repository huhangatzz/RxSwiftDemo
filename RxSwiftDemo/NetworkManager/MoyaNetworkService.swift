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
    case login(data: LoginRequestParam)
}

extension MoyaNetworkService: TargetType {
    var baseURL: URL {
        return URL(string: "http://8.137.116.86:8092")!
    }
    
    var path: String {
        switch self {
            
        case .login:
            return "/home/app/login"
            
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .login:
            return .post
        default:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        
        case let .login(data):
            return .requestJSONEncodable(data)
            
//        case let .contents(style):
//            return .requestParameters(parameters: ["style": style], encoding: URLEncoding.queryString)
        
        default:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        var headers:Dictionary<String,String> = [:]
        headers["Content-Type"] = "application/json"
        
        //登录成功后,才会有session
        
        return headers
    }
}
