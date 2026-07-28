//
//  ActivityIndicator.swift
//  全局加载状态监控工具
//
//  Created by Kaiser on 2026/7/28.
//

import Foundation
import RxSwift
import RxCocoa

//资源哨兵（资源包装器，遵守 Disposable）
private struct ActivityToken<T>: ObservableConvertibleType, Disposable {
    
    //保存原始业务流（网络请求 Observable）
    private let _source: Observable<T>
    //得到遵守Cancelable这个协议的对象
    private let _dispose: Cancelable
    
    init(source: Observable<T>, disposeAction: @escaping () -> Void) {
        _source = source
        // create 返回 AnonymousDisposable（遵守 Cancelable）
        _dispose = Disposables.create(with: disposeAction)
    }
    
    func asObservable() -> Observable<T> {
        _source
    }
    
    func dispose() {
        // 调用遵守协议对象的 dispose() 方法
        _dispose.dispose()
    }
}

/**
 可实现序列计算的监控。
 如果当前正在执行至少一个序列计算，则发送 `true`。
 当所有活动完成后，将发送 `false`。
 */
//核心管理器，计数器、对外暴露 Driver
public class ActivityIndicator: SharedSequenceConvertibleType {
    //去别名
    public typealias Element = Bool
    
    // 共享策略  是一套面向 UI 持续状态的序列行为规范：强制主线程分发、禁止 error、自带缓存共享；
    public typealias SharingStrategy = DriverSharingStrategy
    
    //多线程并发场景，保护计数器读写，防止并发
    private let _lock = NSRecursiveLock()
    
    // 能持有当前的状态 (任务计数器)
    private let _replay = BehaviorRelay(value: 0)
    
    /*
     RxSwift/RxCocoa 内有三大 SharedSequence 策略：
     DriverSharingStrategy → Driver<T>
     SignalSharingStrategy → Signal<T>
     ControlEventSharingStrategy → ControlEvent<T>
     
     SharedSequence<S, E> = 对普通 Observable 包装 + 施加共享策略的序列。
     S 就是共享策略，决定这套序列拥有什么行为约束。
     
     凡是基于 DriverSharingStrategy 的序列（Driver），强制保证 3 条铁律：
     1.不能发出 error
     如果上游产生 error，会直接崩溃。所以上游必须提前处理异常（catchError）
     2.事件一定在主线程（MainScheduler）分发
     天生适合 UI 绑定，不用手动写 observe(on:MainScheduler)
     3.自动共享资源（隐式 share (replay:1)）
     底层等价：share(replay: 1, scope: .whileConnected)
     
     */
    private let _loading: SharedSequence<SharingStrategy, Bool>//实质就是 Driver<Bool>
    
    public init() {
        _loading = _replay.asDriver()//将 BehaviorRelay<Int> 转为 Driver<Int>, Driver<Int> 就是 SharedSequence<DriverSharingStrategy, Int>
            .map({ $0 > 0 })
            .distinctUntilChanged()
    }

    //fileprivate 当前 .swift 源代码文件内可见
    fileprivate func trackActivityOfObservable<Source: ObservableConvertibleType>(_ source: Source) -> Observable<Source.Element> {
        //创建「伴随资源生命周期」的序列
        Observable.using { () -> ActivityToken<Source.Element> in
            self.increment()
            return ActivityToken(source: source.asObservable(), disposeAction: self.decrement)
        } observableFactory: { t in
            t.asObservable()
        }
    }
    
    private func increment() {
        _lock.lock()
        _replay.accept(_replay.value + 1)
        _lock.unlock()
    }
    
    private func decrement() {
        _lock.lock()
        _replay.accept(_replay.value-1)
        _lock.unlock()
    }

    //对外提供统一方法，使用者可以直接调用：
    public func asSharedSequence() -> SharedSequence<DriverSharingStrategy, Bool> {
        _loading
    }
}

//trackActivity() 链式语法糖
public extension ObservableConvertibleType {
    func trackActivity(_ activityIndicator: ActivityIndicator) -> Observable<Element> {
        activityIndicator.trackActivityOfObservable(self)
    }
}
