import Foundation
import RxSwift

final class DefaultNormalRegisterValidationService: NormalRegisterValidationService {
    static let shared = DefaultNormalRegisterValidationService()

    func validatePhone(_ phone: String) -> Bool {
        phone.count == 11 && phone.allSatisfy(\.isNumber)
    }

    func validateCode(_ code: String) -> Bool {
        !code.isEmpty && code.allSatisfy(\.isNumber)
    }
}

final class DefaultNormalRegisterAPI: NormalRegisterAPI {
    static let shared = DefaultNormalRegisterAPI(networkManager: .shared)

    private let networkManager: MoyaNetworkManager

    init(networkManager: MoyaNetworkManager) {
        self.networkManager = networkManager
    }

    func sendVerificationCode(phone: String, type: String) -> Observable<NormalRegisterResponse> {
        request(
            .sendVerificationCode(phone: phone, type: type),
            dataType: [EmptyResponseData].self
        )
    }

    func login(phone: String, code: String) -> Observable<NormalRegisterResponse> {
        request(
            .login(phone: phone, code: code),
            dataType: CurrentUser.self
        )
    }

    /// 统一完成请求、数据解码和业务结果转换。
    private func request<T: Codable>(
        _ target: MoyaNetworkService,
        dataType: T.Type
    ) -> Observable<NormalRegisterResponse> {
        networkManager
            .requestRx(target, as: DataResponse<T>.self)
            .map { response in
                NormalRegisterResponse(
                    success: true,
                    message: response.msg ?? "操作成功",
                    data: response.data
                )
            }
            .catch { error in
                let message: String
                if case let CommonError.networkResponse(response) = error {
                    message = response.msg ?? "请求失败"
                } else {
                    message = "无法连接服务器"
                }

                return .just(
                    NormalRegisterResponse(
                        success: false,
                        message: message,
                        data: nil
                    )
                )
            }
    }
}
