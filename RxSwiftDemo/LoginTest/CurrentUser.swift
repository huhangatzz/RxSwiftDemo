//
//  CurrentUser.swift
//  RxSwiftDemo
//
//  Created by Kaiser on 2026/7/31.
//

import UIKit

// MARK: - ZKUserInfoModel Swift版本
struct CurrentUser: Identifiable, Codable, Hashable {
    var id: String? = nil
    
    var userId: String?
    var phonenumber: String?
    var userName: String?
    var nickName: String?
    var avatar: String?
    /// 用户性别（0男 1女 2未知）
    var sex: String?
    var birthday: String?
    var age: Int = 0
    var height: String?
    var weight: String?
    /// 血型（A/B/O/AB）
    var bloodType: String?
    var medicalHistory: String?
    /// 健康标签 健康0，慢性病1，高危人群2，亚健康3，高负荷人群4
    var healthTag: String?
    var createTime: String?
    var updateTime: String?
    var email: String?
    var latitude: String?
    var longitude: String?
    var admin: Bool = false
}
