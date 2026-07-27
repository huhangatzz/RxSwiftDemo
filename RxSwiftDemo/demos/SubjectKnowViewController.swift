//
//  SubjectKnowViewController.swift
//  RxSwiftDemo
//
//  Created by 胡航 on 2026/7/26.
//

import UIKit
import RxSwift
import RxCocoa

class SubjectKnowViewController: UIViewController {

    let disposeBag = DisposeBag()
    
    enum CacheError: Error {
        case failedCaching
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        asyncSubjectTest()
        print("\n PublishSubject")
        publishSubjectTest()
        print("\n ReplaySubject")
        replaySubjectTest()
        print("\n BehaviorSubject")
        behaviorSubjectTest()
    }
   
    //AsyncSubject
    //将在源 Observable 产生完成事件后，发出最后一个元素（仅仅只有最后一个元素），如果源 Observable 没有发出任何元素，只有一个完成事件。那 AsyncSubject 也只有一个完成事件。
    func asyncSubjectTest() {
        let subject = AsyncSubject<String>()
        
        subject
            .subscribe {
                print("Subscription: 1 Event:", $0)
            }
            .disposed(by: disposeBag)
        
            subject.onNext("🐶")  // 暂存，不推送
            subject.onNext("🐱")  // 覆盖暂存
            subject.onNext("🐹")  // 覆盖暂存，现在保存最后值🐹
            subject.onCompleted() // 触发：推送缓存的最后一个值🐹，再推送completed
    }
    
    //PublishSubject 将对观察者发送订阅后产生的元素发生给观察者，而在订阅前发出的元素将不会发送给观察者
    func publishSubjectTest() {
        let subject = PublishSubject<String>()
        
        subject.onNext("胡航最帅")
        
        subject
            .subscribe { print("Subscription: 1 Event:", $0) }
            .disposed(by: disposeBag)
    
        subject.onNext("🐶")
        subject.onNext("🐱")
        
        subject
            .subscribe { print("Subscription: 2 Event:", $0) }
            .disposed(by: disposeBag)
        
        subject.onNext("🅰️")
        subject.onNext("🅱️")
    }
    
    //ReplaySubject 将对观察者发送全部的元素，无论观察者是何时进行订阅的。
    func replaySubjectTest() {
        // bufferSize = 1：只缓存【最近1条】事件
        let subject = ReplaySubject<String>.create(bufferSize: 1)

        // 订阅1
        subject
          .subscribe { print("Subscription: 1 Event:", $0) }
          .disposed(by: disposeBag)

        subject.onNext("🐶") // 缓存：[🐶]，推送订阅1
        subject.onNext("🐱") // 缓存淘汰旧值 → [🐱]，推送订阅1

        // 新增订阅2
        // ReplaySubject立刻补发缓冲区保存的 最近1条：🐱
        subject
          .subscribe { print("Subscription: 2 Event:", $0) }
          .disposed(by: disposeBag)

        subject.onNext("🅰️") // 缓存更新[🅰️]，同时广播给 订阅1、订阅2
        subject.onNext("🅱️") // 缓存更新[🅱️]，同时广播给 订阅1、订阅2
    }

    //BehaviorSubject 当观察者对 BehaviorSubject 进行订阅时，它会将源 Observable 中最新的元素发送出来（如果不存在最新的元素，就发出默认元素）。然后将随后产生的元素发送出来。
    func behaviorSubjectTest() {
        let subject = BehaviorSubject(value: "🔴")
        
        subject
          .subscribe { print("Subscription: 1 Event:", $0) }
          .disposed(by: disposeBag)

        subject.onNext("🐶")
        subject.onNext("🐱")

        subject
          .subscribe { print("Subscription: 2 Event:", $0) }
          .disposed(by: disposeBag)

        subject.onNext("🅰️")
        subject.onNext("🅱️")
        
        subject
          .subscribe { print("Subscription: 3 Event:", $0) }
          .disposed(by: disposeBag)

        subject.onNext("🍐")
        subject.onNext("🍊")
    }
}
