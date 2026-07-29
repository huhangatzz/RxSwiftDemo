import Foundation
import RxSwift

struct NormalRegisterResponse {
    let success: Bool
    let message: String
    let data: Any?
}

protocol NormalRegisterAPI {
    func sendVerificationCode(phone: String, type: String) -> Observable<NormalRegisterResponse>
    func login(phone: String, code: String) -> Observable<NormalRegisterResponse>
}

protocol NormalRegisterValidationService {
    func validatePhone(_ phone: String) -> Bool
    func validateCode(_ code: String) -> Bool
}
