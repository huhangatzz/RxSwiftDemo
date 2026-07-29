import Foundation
import RxSwift
import RxCocoa

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
    static let shared = DefaultNormalRegisterAPI(session: .shared)

    private static let commonHeaders = [
        "User-Agent": "zhikon/1.3.22 (iPhone; iOS 26.5.2; Scale/3.00)",
        "Accept-Language": "zh-Hans-CN;q=1",
        "Accept": "*/*",
        "deviceCode": "",
        "Accept-Encoding": "gzip, deflate"
    ]

    private let baseURL = URL(string: "http://8.137.116.86:8092")!
    private let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    func sendVerificationCode(phone: String, type: String) -> Observable<NormalRegisterResponse> {
        post(path: "/send", parameters: [
            "phone": phone,
            "type": type
        ])
    }

    func login(phone: String, code: String) -> Observable<NormalRegisterResponse> {
        post(path: "/home/app/login", parameters: [
            "phone": phone,
            "code": code
        ])
    }

    private func post(path: String, parameters: [String: String]) -> Observable<NormalRegisterResponse> {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        Self.commonHeaders.forEach {
            request.setValue($0.value, forHTTPHeaderField: $0.key)
        }

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            return .error(error)
        }

        return session.rx.response(request: request)
            .map { response, data in
                let body = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
                let message = body?["msg"] as? String
                    ?? HTTPURLResponse.localizedString(forStatusCode: response.statusCode)
                let businessCode = body?["code"] as? Int
                let success = (200..<300).contains(response.statusCode)
                    && (businessCode == nil || businessCode == 0 || businessCode == 200)
                return NormalRegisterResponse(
                    success: success,
                    message: message,
                    data: body?["data"]
                )
            }
    }
}
