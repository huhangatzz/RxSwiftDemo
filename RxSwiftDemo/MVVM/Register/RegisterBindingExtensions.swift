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

/*
 这样写的目的:
 自定义一个 Binder,让你可以直接用 .bind(to: label.rx.validationResult) 优雅绑定校验结果到 UILabel
 这是 RxSwift UI 绑定的标准最佳实践 专门解决两件事：
 1. UI 绑定强制在主线程执行；
 2. 屏蔽上游 error，不让网络 / 校验异常直接崩溃页面；
 3. 把「标签文字 + 颜色更新」封装成可复用的响应式属性。
 
 优点:
 复用：项目所有校验标签，直接 .rx.validationResult；
 主线程保障，不用手动调度；
 容错，error 不会摧毁 UI 绑定；
 语义清晰：数据流 → 绑定到标签校验结果，声明式风格，MVVM 标配；
 完美配合 .bind(to:) 链式语法。
 */
extension Reactive where Base: UILabel {
    var validationResult: Binder<ValidationResult> {
        Binder(base) { label, result in
            label.textColor = result.textShowColor
            label.text = result.description
        }
    }
}
