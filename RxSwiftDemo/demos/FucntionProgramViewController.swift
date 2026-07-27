//
//  FucntionProgramViewController.swift
//  RxSwiftDemo
//
//  Created by 胡航 on 2026/7/25.
//

import UIKit
import Foundation

class FucntionProgramViewController: UIViewController {

    enum Sex {
        case male
        case female
    }
    
    struct Parent {
        let name: String
        
        func receiveAPrize() {
            print("🏆 \(name) 上台领奖！")
        }
    }
    
    struct Student {
        let name: String
        let grade: Int
        let `class`: Int
        let sex: Sex
        let score: Int
        let parent: Parent
        
        func singASong(song: String) {
            print("🎤 \(name) 演唱：《\(song)》")
        }
    }
    
    func getSchoolStudents() -> [Student] {
        return [
            Student(name: "小明", grade: 3, class: 2, sex: .male, score: 95, parent: Parent(name: "明爸爸")),
            Student(name: "小红", grade: 3, class: 2, sex: .female, score: 88, parent: Parent(name: "红妈妈")),
            Student(name: "小刚", grade: 3, class: 2, sex: .male, score: 55, parent: Parent(name: "刚爸爸")),
            Student(name: "小丽", grade: 3, class: 2, sex: .female, score: 92, parent: Parent(name: "丽妈妈")),
            Student(name: "小宇", grade: 3, class: 2, sex: .male, score: 58, parent: Parent(name: "宇爸爸")),
            Student(name: "小航", grade: 2, class: 1, sex: .male, score: 52, parent: Parent(name: "航爸爸")),
            Student(name: "小诺", grade: 2, class: 1, sex: .female, score: 77, parent: Parent(name: "诺妈妈")),
            Student(name: "小杰", grade: 4, class: 1, sex: .male, score: 91, parent: Parent(name: "杰爸爸")),
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "函数式编程"
        
        let allStudents: [Student] = getSchoolStudents()
        
        //filter过滤数据 三年二班的学生
        let gradeThreeClassTwoStudents: [Student] = allStudents
            .filter { student in return student.grade == 3 && student.class == 2 }
        print(gradeThreeClassTwoStudents.map({ $0.name }))
        
        // 三年二班的每一个男同学唱一首《一剪梅》
        gradeThreeClassTwoStudents
            .filter { student in return student.sex == .male }
            .forEach { boy in boy.singASong(song: "一剪梅") }
        
        // 3. 三年二班学生成绩高于90分的家长上台领奖
        gradeThreeClassTwoStudents
            .filter { student in student.score > 90 }
            //map把数组里每一个元素，转换成另一种数据，返回新数组
            .map { student in student.parent } // 学生数组 → 家长数组
            .forEach { parent in parent.receiveAPrize() }
        
        // 4. 由高到低打印三年二班的学生成绩
        gradeThreeClassTwoStudents
            .sorted { student0, student1 in student0.score > student1.score }
            .forEach { student in print("score: \(student.score), name: \(student.name)")}
        
        // 需求：二年一班分数不足60的学生唱一首《我有罪》
        allStudents
            .filter { student in student.grade == 2 && student.class == 1 && student.score < 60 }
            .forEach { student in student.singASong(song: "我有罪")}
        
        /*
         总结:
         filter：数量变化，类型不变（挑选元素）
         map：类型可以变，数量不变（改造元素）
         forEach: 不生成新数组，无返回值 (遍历执行)
         sorted: 类型不变、数量不变，顺序改变
         */
    }

}
