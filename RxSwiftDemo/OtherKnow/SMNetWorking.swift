//
//  SMNetWorking.swift
//  RxSwiftDemo
//
//  Created by Kaiser on 2026/8/7.
//

import UIKit

/*
 infix   中间运算符 运算符写在两个操作数中间，如 a << b
 prefix  前者运算符 运算符写在变量前面，例：-a、!b
 postfix 后置运算符 运算符写在变量后面，例：c!（隐式解包）
 */

enum HTTPMethod: String {
    case GET, OPTIONS, HEAD, POST, PUT, PATCH, DELETE, TRACE, CONNECT
}

open class SMNetWorking<T: Codable> {
    public let session: URLSession
    
    //就是OC中的Block
    typealias CompletionJSONClosure = (_ data: T) -> Void
    var completionJSONClosure: CompletionJSONClosure = {_ in }
    
    public init() {
        self.session = URLSession.shared
    }
    
    //JSON的请求
    func requestJSON(_ url: SMURLNetWorking, doneClosure: @escaping CompletionJSONClosure) {
        self.completionJSONClosure = doneClosure
        
        let request: URLRequest = NSURLRequest.init(url: url.asURL()) as URLRequest
        let task = self.session.dataTask(with: request) { data, res, error in
            if (error == nil) {
                let decoder = JSONDecoder()
                do {
                    print("解析JSON成功")
                    let jsonModel = try decoder.decode(T.self, from: data!)
                    self.completionJSONClosure(jsonModel)
                } catch {
                    print("解析JSON失败")
                }
            }
        }
        task.resume()
    }
}

protocol SMURLNetWorking {
    func asURL() -> URL
}

extension String: SMURLNetWorking {
    func asURL() -> URL {
        guard let url = URL(string: self) else {
            return URL(string: "http://www.starming.com")!
        }
        return url
    }
}


//测试模型

// MARK: - RandomUserResponse
struct RandomUserResponse: Codable {
    let results: [RandomUserItem]
    let info: RandomUserInfo
}

// MARK: - RandomUserInfo
struct RandomUserInfo: Codable {
    let seed: String
    let results: Int
    let page: Int
    let version: String
}

// MARK: - RandomUserItem
struct RandomUserItem: Codable {
    let gender: String
    let name: RandomUserName
    let location: RandomUserLocation
    let email: String
    let login: RandomUserLogin
    let dob: RandomUserDob
    let registered: RandomUserRegistered
    let phone: String
    let cell: String
    let id: RandomUserID
    let picture: RandomUserPicture
    let nat: String
}

// MARK: - RandomUserName
struct RandomUserName: Codable {
    let title: String
    let first: String
    let last: String
}

// MARK: - RandomUserLocation
struct RandomUserLocation: Codable {
    let street: RandomUserStreet
    let city: String
    let state: String
    let country: String
    let postcode: Int
    let coordinates: RandomUserCoordinates
    let timezone: RandomUserTimezone
}

// MARK: - RandomUserStreet
struct RandomUserStreet: Codable {
    let number: Int
    let name: String
}

// MARK: - RandomUserCoordinates
struct RandomUserCoordinates: Codable {
    let latitude: String
    let longitude: String
}

// MARK: - RandomUserTimezone
struct RandomUserTimezone: Codable {
    let offset: String
    let description: String
}

// MARK: - RandomUserLogin
struct RandomUserLogin: Codable {
    let uuid: String
    let username: String
    let password: String
    let salt: String
    let md5: String
    let sha1: String
    let sha256: String
}

// MARK: - RandomUserDob
struct RandomUserDob: Codable {
    let date: String
    let age: Int
}

// MARK: - RandomUserRegistered
struct RandomUserRegistered: Codable {
    let date: String
    let age: Int
}

// MARK: - RandomUserID
struct RandomUserID: Codable {
    let name: String
    let value: String? // value有可能为null，可选
}

// MARK: - RandomUserPicture
struct RandomUserPicture: Codable {
    let large: String
    let medium: String
    let thumbnail: String
}
