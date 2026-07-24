//
//  ScrollDemoViewController.swift
//  RxSwiftDemo
//
//  Created by Kaiser on 2026/7/24.
//

import UIKit
import SnapKit

enum DemoPalette {
    static let background = UIColor.cyan
    static let card = UIColor.secondarySystemGroupedBackground//动态系统颜色
    static let blue = UIColor.systemBlue
    static let purple = UIColor.systemPurple
    static let orange = UIColor.systemOrange
    static let green = UIColor.systemGreen
}

extension UILabel {
    static func demoLabel(_ text: String? = nil, font: UIFont = .systemFont(ofSize: 15), color: UIColor = .label) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = color
        label.numberOfLines = 0
        return label
    }
}

extension UITextField {
    static func demoTextField(_ placeholder: String? = nil) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.returnKeyType = .done
        return textField
    }
}

extension UIView {
    static func demoBox(_ color: UIColor, cornerRadius: CGFloat = 10) -> UIView {
        let view = UIView()
        view.backgroundColor = color
        view.layer.cornerRadius = cornerRadius
        return view
    }
}

class ScrollDemoViewController: UIViewController {
    let scrollView = UIScrollView()
    let contentView = UIView()
    let contentStack = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DemoPalette.background
        
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.backgroundColor = .purple
        contentView.addSubview(contentStack)
        
        contentView.backgroundColor = .brown
        scrollView.addSubview(contentView)
        
        scrollView.backgroundColor = .red
        view.addSubview(scrollView)
        
        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)// 滚动内容区域边界
            make.width.equalTo(scrollView.frameLayoutGuide)// scrollView 自身 bounds
        }
        
        contentStack.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
        }
    }
    
    //添加分区文案
    @discardableResult
    func addSection(_ title: String, note: String? = nil) -> UIView {
        let cardView = UIView.demoBox(DemoPalette.card, cornerRadius: 14)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        cardView.addSubview(stackView)
        
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(12)
        }
        
        //标题 (addArrangedSubview: 让stackView自动给它生成约束)
        stackView.addArrangedSubview(UILabel.demoLabel(title, font: .boldSystemFont(ofSize: 17)))
        
        //提示
        if let note = note {
            stackView.addArrangedSubview(UILabel.demoLabel(note, font: .systemFont(ofSize: 13), color: .secondaryLabel))
        }
        
        contentStack.addArrangedSubview(cardView)
        
        return cardView
    }

    //获取cardView里面的UIStackView
    func sectionStack(in cardView: UIView) -> UIStackView {
        return cardView.subviews.compactMap { $0 as? UIStackView }.first!
    }
}
