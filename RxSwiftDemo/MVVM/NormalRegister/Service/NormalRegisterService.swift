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
        mapResponse(
            networkManager.sendVerificationCode(phone: phone, type: type)
        )
    }

    func login(phone: String, code: String) -> Observable<NormalRegisterResponse> {
        mapResponse(
            networkManager.loginRx(
                data: LoginRequestParam(phone: phone, code: code)
            )
        )
    }

    private func mapResponse<T: Codable>(
        _ observable: Observable<DataResponse<T>>
    ) -> Observable<NormalRegisterResponse> {
        observable
            .map { response in
                return NormalRegisterResponse(
                    success: response.code == 200,
                    message: response.msg ?? "操作成功",
                    data: response.data
                )
            }
            .catch { error in
                guard case let CommonError.networkResponse(response) = error else {
                    return .error(error)
                }

                return .just(
                    NormalRegisterResponse(
                        success: false,
                        message: response.msg ?? "请求失败",
                        data: nil
                    )
                )
            }
    }
}
