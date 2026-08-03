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

        //点击获取验证码
        let sendCodeTapContext = input.sendCodeTaps
            .withLatestFrom(Observable.combineLatest(input.phone, agreementSelected))
            .share()

        agreementRequired = sendCodeTapContext
            .filter { !$0.1 } // 表示只保留“协议未勾选”的点击事件
            .map { _ in () } // 表示把收到的内容转换为 Void

        let sendCodeResponse = sendCodeTapContext
            .filter { $0.1 } // 表示只保留“协议已勾选”的点击事件
            .map { $0.0 } //取出手机号
            .flatMapLatest { phone in
                API.sendVerificationCode(phone: phone, type: "login")
                    .trackActivity(sendingCode)
                    .observe(on: MainScheduler.instance)
            }
            .share(replay: 1)

        // \.success 是 Swift 的 KeyPath（键路径）语法，表示读取每个响应对象的 success 属性。
        let countdown = sendCodeResponse
            // 只让 success == true 的响应继续向下传递
            .filter(\.success) //相当于 .filter { response in response.success }
            // 验证码发送成功后启动倒计时
            .flatMapLatest { _ in
                Observable<Int>.timer(
                    .seconds(0),//延迟 0 秒开始，也就是立即开始
                    period: .seconds(1),//每隔 1 秒发出一个整数
                    scheduler: MainScheduler.instance //在主线程执行，方便更新 UI
                )
                .map { 60 - $0 } //把递增序列转换成递减序列
                .take(while: { $0 >= 0 }) // 到 0 为止
            }
            .share(replay: 1)

        let countingDown = countdown
            .map { $0 > 0 }
            .startWith(false)// 在倒计时还没有开始前，先提供一个初始状态：这样刚进入页面时，系统就知道当前没有倒计时
            .distinctUntilChanged()
            .share(replay: 1)

        countdownTitle = countdown
            .map { $0 > 0 ? "\($0)s" : "获取验证码" }
            .startWith("获取验证码")
            .share(replay: 1)

        //phoneValid 这个局部变量消失了
        //phoneValid 指向的 Observable 仍然被 sendCodeEnabled 间接持有。
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
            }
            .flatMapLatest { response in
                wireframe.promptFor(response.message, cancelAction: "确定", actions: [])
                    .map { _ in response }
            }
            .share(replay: 1)
    }
}
