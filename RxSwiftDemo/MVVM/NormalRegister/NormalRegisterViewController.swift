import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class NormalRegisterViewController: UIViewController {
    private let registerView = NormalRegisterView()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "登录"
        createUI()
        bindViewModel()
    }

    private func createUI() {
        view.backgroundColor = .white
        view.addSubview(registerView)

        registerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func bindViewModel() {
        
        let viewModel = NormalRegisterViewModel(
            input: (
                phone: registerView.phoneTextField.rx.text.orEmpty.asObservable(),
                code: registerView.codeTextField.rx.text.orEmpty.asObservable(),
                agreementTaps: registerView.agreementButton.rx.tap.asObservable(),
                sendCodeTaps: registerView.sendCodeButton.rx.tap.asObservable(),
                loginTaps: registerView.loginButton.rx.tap.asObservable()
            ),
            dependency: (
                API: DefaultNormalRegisterAPI.shared,
                validationService: DefaultNormalRegisterValidationService.shared,
                wireframe: DefaultWireframe.shared
            )
        )

        viewModel.agreementSelected
            .map { UIImage(named: $0 ? "icon_login_checkbox_selected" : "icon_login_checkbox") }
            .bind(to: registerView.agreementButton.rx.image())
            .disposed(by: disposeBag)

        viewModel.countdownTitle
            .subscribe(onNext: { [weak self] title in
                self?.registerView.updateCountdownTitle(title)
            })
            .disposed(by: disposeBag)

        viewModel.sendCodeEnabled
            .bind(to: registerView.sendCodeButton.rx.isEnabled)
            .disposed(by: disposeBag)

        viewModel.agreementRequired
            .subscribe(onNext: { [weak self] in
                self?.registerView.showAgreementRequiredFeedback()
            })
            .disposed(by: disposeBag)

        viewModel.loginEnabled
            .subscribe(onNext: { [weak self] enabled in
                self?.registerView.updateLoginEnabled(enabled)
            })
            .disposed(by: disposeBag)

        viewModel.loggingIn
            .bind(to: registerView.activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)

        viewModel.sendCodeResult
            .subscribe(onNext: { response in
                print("验证码接口 data:", response.data ?? "nil")
            })
            .disposed(by: disposeBag)

        viewModel.loginResult
            .subscribe()
            .disposed(by: disposeBag)

        let backgroundTap = UITapGestureRecognizer()
        backgroundTap.rx.event
            .subscribe(onNext: { [weak self] _ in self?.view.endEditing(true) })
            .disposed(by: disposeBag)
        view.addGestureRecognizer(backgroundTap)
    }

}
