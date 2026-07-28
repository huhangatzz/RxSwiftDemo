//
//  String+URL.swift
//  RxSwiftDemo
//
//  Created by Kaiser on 2026/7/28.
//

import Foundation

extension String {
    var URLScaped: String {
        //把中文、空格、特殊符号转换成网络地址能正常识别的格式，避免拼接 URL 时地址失效、参数错乱
        addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    }
}
