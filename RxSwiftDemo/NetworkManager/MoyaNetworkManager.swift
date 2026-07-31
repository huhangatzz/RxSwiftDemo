//
//  MoyaNetworkManager.swift
//  扩展moya异步任务
//
//  Created by Kaiser on 2026/7/31.
//

import Foundation
import Moya
import RxSwift

struct EmptyResponseData: Codable {}

//网络请求的仓库
class MoyaNetworkManager {
    static let shared = MoyaNetworkManager()
    
    private var provider: MoyaProvider<MoyaNetworkService>!
    
    /// 通用 RxSwift 请求，新增业务接口时无需修改 Manager。
    func requestRx<T: BaseResponse>(_ target: MoyaNetworkService, as responseType: T.Type) -> Observable<T> {
        provider.runRequestRx(target)
    }
    
    private init() {
        var plugins: [PluginType] = []
        
        //网络日志插件 上线需要隐藏
        plugins.append(NetworkLoggerPlugin(configuration: NetworkLoggerPlugin.Configuration(logOptions: .successResponseBody)))
        
        let requestClosure = { (endpoint: Endpoint, done: @escaping MoyaProvider<MoyaNetworkService>.RequestResultClosure) in
            do {
                var request = try endpoint.urlRequest()
                request.timeoutInterval = 15
                done(.success(request))
            } catch {
                done(.failure(MoyaError.underlying(error, nil)))
            }
        }
        
        provider = MoyaProvider<MoyaNetworkService>(requestClosure: requestClosure, plugins: plugins)
    }
}
