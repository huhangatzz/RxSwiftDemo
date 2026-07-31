//
//  MoyaProviderExtension.swift
//  RxSwiftDemo
//
//  Created by Kaiser on 2026/7/31.
//

import UIKit
import Moya

//错误类型
enum CommonError: Error {
    case networkResponse(BaseResponse)
    case userNotFound
}

//根据接口返回的结果定义的根模型
class BaseResponse : Codable {
    var code: Int = 0
    var msg: String? = nil
}

//详情接口返回数据
class DataResponse<T: Codable>: BaseResponse {
    // 业务详情数据，可选：接口无data字段、data为null时为nil
    var data: T?
    
    // 自定义解码键，只映射当前子类独有字段data
    private enum CodingKeys: String, CodingKey {
        case data
    }
    
    // 自定义解码器构造方法，实现Codable手动解码
    //为什么这里需要自定义解码器:子类、父类如果各自有独立 CodingKeys，自动生成的解码逻辑不能同时解析父子两层 key，会只解析子类自己的 data，丢失父类 status/message。
    required init(from decoder: Decoder) throws {
        // 取出当前类CodingKeys对应的解码容器
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // try? 容错解码：data不存在/类型不匹配不会崩溃，直接赋值nil
        self.data = try? container.decode(T.self, forKey: .data)
        
        // 调用父类BaseResponse的解码构造，解析code、message等公共字段
        try super.init(from: decoder)
    }
}

//封装的网络工具类
// 扩展MoyaProvider，泛型Target为Moya TargetType
extension MoyaProvider {
    /// 通用网络请求封装，async/await风格
    /// - Parameter target: Moya接口Target
    /// - Returns: 解析后的BaseResponse子类对象，可选
    func runRequest<T: BaseResponse>(_ target: Target) async throws -> T? {
        do {
            // 1. 将Moya回调API桥接为async await（withCheckedThrowingContinuation桥接回调）
            let response = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Response, Error>) in
                // 原始Moya回调请求
                self.request(target) { result in
                    switch result {
                    case .success(let r):
                        // 请求成功，把Response丢给async流程
                        continuation.resume(returning: r)
                    case .failure(let error):
                        // 网络层面失败（超时、无网、连接失败等），抛出错误
                        continuation.resume(throwing: error)
                    }
                }
            }
            
            // 2. 过滤HTTP状态码：非200~299直接抛Moya.MoyaError
            let filteredResponse = try response.filterSuccessfulStatusCodes()
            
            // 3. JSON自动解码为泛型T（必须继承BaseResponse且遵守Codable）
            let decodedObject = try filteredResponse.map(T.self)
            
            // 4. 业务层判断：后端约定status=200才代表成功，非200抛业务错误
            if decodedObject.code != 200 {
                throw CommonError.networkResponse(decodedObject)
            }
            
            // 成功返回解析好的模型
            return decodedObject
        } catch {
            // 所有层级错误统一上抛给外部调用方处理
            throw error
        }
    }
}
