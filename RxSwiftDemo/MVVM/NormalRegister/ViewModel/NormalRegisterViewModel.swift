import Foundation
import RxSwift
import RxCocoa

final class NormalRegisterViewModel {
    let sendCodeEnabled: Observable<Bool>
    let loginEnabled: Observable<Bool>
    let sendingCode: Observable<Bool>
    let loggingIn: Observable<Bool>
    let agreementSelected: Observable<Bool>
    let agreementRequired: Observable<Void>
    
    let countdownTitle: Observable<String>
    let sendCodeResult: Observable<NormalRegisterResponse>
    let loginResult: Observable<NormalRegisterResponse>

    init(
        input: (
            phone: Observable<String>,
            code: Observable<String>,
            agreementTaps: Observable<Void>,
            sendCodeTaps: Observable<Void>,
            loginTaps: Observable<Void>
        ),
        dependency: (
            API: NormalRegisterAPI,
            validationService: NormalRegisterValidationService,
            wireframe: Wireframe
        )
    ) {
        let API = dependency.API
        let validationService = dependency.validationService
        let wireframe = dependency.wireframe

        let sendingCode = ActivityIndicator()
        let loggingIn = ActivityIndicator()
        
        self.sendingCode = sendingCode.asObservable()
        self.loggingIn = loggingIn.asObservable()

        agreementSelected = input.agreementTaps
            .scan(false) { selected, _ in !selected }
            .startWith(false)
            .distinctUntilChanged()
            .share(replay: 1)

        let phoneValid = input.phone
            .map(validationService.validatePhone)
            .distinctUntilChanged()
            .share(replay: 1)

        let codeValid = input.code
            .map(validationService.validateCode)
            .distinctUntilChanged()
            .share(replay: 1)

        let sendCodeTapContext = input.sendCodeTaps
            .withLatestFrom(Observable.combineLatest(input.phone, agreementSelected))
            .share()

        agreementRequired = sendCodeTapContext
            .filter { !$0.1 }
            .map { _ in () }

        let sendCodeResponse = sendCodeTapContext
            .filter { $0.1 }
            .map { $0.0 }
            .flatMapLatest { phone in
                API.sendVerificationCode(phone: phone, type: "login")
                    .trackActivity(sendingCode)
                    .observe(on: MainScheduler.instance)
                    .catchAndReturn(.init(success: false, message: "无法连接服务器", data: nil))
            }
            .share(replay: 1)

        let countdown = sendCodeResponse
            .filter(\.success)
            .flatMapLatest { _ in
                Observable<Int>.timer(
                    .seconds(0),
                    period: .seconds(1),
                    scheduler: MainScheduler.instance
                )
                .map { 60 - $0 }
                .take(while: { $0 >= 0 })
            }
            .share(replay: 1)

        let countingDown = countdown
            .map { $0 > 0 }
            .startWith(false)
            .distinctUntilChanged()
            .share(replay: 1)

        countdownTitle = countdown
            .map { $0 > 0 ? "\($0)s" : "获取验证码" }
            .startWith("获取验证码")
            .share(replay: 1)

        sendCodeEnabled = Observable.combineLatest(
            phoneValid,
            countingDown,
            sendingCode.asObservable()
        ) { phoneValid, countingDown, sending in
            phoneValid && !countingDown && !sending
        }
        .distinctUntilChanged()
        .share(replay: 1)

        loginEnabled = Observable.combineLatest(
            phoneValid,
            codeValid,
            agreementSelected,
            loggingIn.asObservable()
        ) { phoneValid, codeValid, agreementSelected, loggingIn in
            phoneValid && codeValid && agreementSelected && !loggingIn
        }
        .distinctUntilChanged()
        .share(replay: 1)

        sendCodeResult = sendCodeResponse
            .flatMapLatest { response in
                wireframe.promptFor(response.message, cancelAction: "确定", actions: [])
                    .map { _ in response }
            }
            .share(replay: 1)

        let phoneAndCode = Observable.combineLatest(input.phone, input.code) {
            (phone: $0, code: $1)
        }

        loginResult = input.loginTaps
            .withLatestFrom(phoneAndCode)
            .flatMapLatest { pair in
                API.login(phone: pair.phone, code: pair.code)
                    .trackActivity(loggingIn)
                    .observe(on: MainScheduler.instance)
                    .catchAndReturn(.init(success: false, message: "无法连接服务器", data: nil))
            }
            .flatMapLatest { response in
                wireframe.promptFor(response.message, cancelAction: "确定", actions: [])
                    .map { _ in response }
            }
            .share(replay: 1)
    }
}
