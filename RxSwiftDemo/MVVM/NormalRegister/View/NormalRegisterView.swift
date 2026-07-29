import UIKit
import SnapKit

final class RegisterInputRowView: UIView {
    let textField = UITextField()

    private let iconView = UIImageView()
    private let separatorView = UIView()
    private let trailingView: UIView?

    init(icon: UIImage?, trailingView: UIView? = nil) {
        self.trailingView = trailingView
        super.init(frame: .zero)

        iconView.image = icon
        createUI()
        layoutUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createUI() {
        iconView.tintColor = .systemGray2
        iconView.contentMode = .scaleAspectFit
        addSubview(iconView)

        textField.clearButtonMode = .whileEditing
        textField.font = .systemFont(ofSize: 17)
        textField.textColor = .label
        addSubview(textField)

        separatorView.backgroundColor = .systemGray5
        addSubview(separatorView)

        if let trailingView {
            addSubview(trailingView)
        }
    }

    private func layoutUI() {
        snp.makeConstraints { make in
            make.height.equalTo(64)
        }

        iconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(22)
        }

        textField.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()

            if let trailingView {
                make.trailing.equalTo(trailingView.snp.leading).offset(-8)
            } else {
                make.trailing.equalToSuperview().inset(16)
            }
        }

        if let trailingView {
            trailingView.snp.makeConstraints { make in
                make.trailing.equalToSuperview().inset(16)
                make.centerY.equalToSuperview()
                make.width.equalTo(100)
                make.height.equalTo(44)
            }
        }

        separatorView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
}

final class NormalRegisterView: UIView, UITextFieldDelegate {
    let sendCodeButton = UIButton(type: .custom)
    let agreementButton = UIButton(type: .custom)
    let loginButton = UIButton(type: .custom)
    let activityIndicator = UIActivityIndicatorView(style: .medium)

    var phoneTextField: UITextField { phoneInputRow.textField }
    var codeTextField: UITextField { codeInputRow.textField }

    private let contentView = UIView()
    private lazy var phoneInputRow = RegisterInputRowView(
        icon: UIImage(systemName: "person")
    )
    private lazy var codeInputRow = RegisterInputRowView(
        icon: UIImage(systemName: "lock"),
        trailingView: sendCodeButton
    )
    private let agreementLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        createUI()
        layoutUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        createUI()
        layoutUI()
    }

    func createUI() {
        backgroundColor = .white

        contentView.backgroundColor = UIColor(red: 0.84, green: 0.88, blue: 0.88, alpha: 1)
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        addSubview(contentView)

        phoneTextField.placeholder = "请输入手机号码"
        phoneTextField.keyboardType = .phonePad
        phoneTextField.delegate = self
        contentView.addSubview(phoneInputRow)

        codeTextField.placeholder = "请输入验证码"
        codeTextField.keyboardType = .numberPad

        sendCodeButton.setTitle("获取验证码", for: .normal)
        sendCodeButton.setTitleColor(.systemOrange, for: .normal)
        sendCodeButton.setTitleColor(.systemGray2, for: .disabled)
        sendCodeButton.titleLabel?.font = .systemFont(ofSize: 16)
        contentView.addSubview(codeInputRow)

        agreementButton.setImage(UIImage(named: "icon_login_checkbox"), for: .normal)
        agreementButton.tintColor = .white
        contentView.addSubview(agreementButton)

        agreementLabel.font = .systemFont(ofSize: 15)
        agreementLabel.numberOfLines = 1
        agreementLabel.adjustsFontSizeToFitWidth = true
        agreementLabel.minimumScaleFactor = 0.8
        agreementLabel.attributedText = agreementText()
        contentView.addSubview(agreementLabel)

        loginButton.setTitle("确定", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.titleLabel?.font = .systemFont(ofSize: 20)
        loginButton.backgroundColor = UIColor(red: 0.12, green: 0.70, blue: 0.69, alpha: 1)
        loginButton.layer.cornerRadius = 25
        loginButton.clipsToBounds = true
        addSubview(loginButton)

        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
        loginButton.addSubview(activityIndicator)
    }

    func layoutUI() {
        contentView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        phoneInputRow.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }

        codeInputRow.snp.makeConstraints { make in
            make.top.equalTo(phoneInputRow.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }

        agreementButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(codeInputRow.snp.bottom).offset(18)
            make.size.equalTo(24)
            make.bottom.equalToSuperview().inset(18)
        }

        agreementLabel.snp.makeConstraints { make in
            make.leading.equalTo(agreementButton.snp.trailing).offset(6)
            make.trailing.equalToSuperview().inset(10)
            make.centerY.equalTo(agreementButton)
        }

        loginButton.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.bottom).offset(44)
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.equalTo(50)
        }

        activityIndicator.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(24)
        }
    }

    func updateLoginEnabled(_ enabled: Bool) {
        loginButton.isEnabled = enabled
        loginButton.alpha = enabled ? 1 : 0.5
    }

    func updateCountdownTitle(_ title: String) {
        UIView.performWithoutAnimation {
            sendCodeButton.setTitle(title, for: .normal)
            sendCodeButton.layoutIfNeeded()
        }
    }

    func showAgreementRequiredFeedback() {
        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.prepare()
        feedbackGenerator.notificationOccurred(.warning)

        agreementLabel.layer.removeAnimation(forKey: "agreementShake")
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.values = [-8, 8, -6, 6, -3, 3, 0]
        animation.duration = 0.4
        agreementLabel.layer.add(animation, forKey: "agreementShake")
    }

    //代理
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField === phoneTextField,
              let currentText = textField.text,
              let textRange = Range(range, in: currentText) else {
            return true
        }

        let updatedText = currentText.replacingCharacters(in: textRange, with: string)
        return updatedText.count <= 11
    }

    private func agreementText() -> NSAttributedString {
        let text = "已阅读并同意《用户协议》和《隐私政策》"
        let result = NSMutableAttributedString(
            string: text,
            attributes: [.foregroundColor: UIColor.label]
        )

        ["《用户协议》", "《隐私政策》"].forEach { item in
            result.addAttribute(
                .foregroundColor,
                value: UIColor.systemOrange,
                range: (text as NSString).range(of: item)
            )
        }
        return result
    }
}
