//
//  RegisterBindingExtensions.swift
//  RxSwiftDemo
//
//  Created by Kaiser on 2026/7/28.
//

import Foundation
import RxCocoa
import RxSwift

enum ValidationColors {
    static let okColor = UIColor(red: 138.0/255.0, green: 221.0/255.0, blue: 109.0/255.0, alpha: 1.0)
    static let errorColor = UIColor.red
}

// 扩展描述文本计算属性
extension ValidationResult: CustomStringConvertible {
    var description: String {
        switch self {
        case let .ok(message):
            message
        case .empty:
            ""
        case .validating:
            "验证中"
        case let .failed(message):
            message
        }
    }
}

// 给枚举扩展颜色计算属性
extension ValidationResult {
    var textShowColor: UIColor {
        switch self {
        case .ok:
            ValidationColors.okColor
        case .empty:
            UIColor.black
        case .validating:
            UIColor.purple
        case .failed:
            ValidationColors.errorColor
        }
    }
}

extension Reactive where Base: UILabel {
    var validationResult: Binder<ValidationResult> {
        Binder(base) { label, result in
            label.textColor = result.textShowColor
            label.text = result.description
        }
    }
}
