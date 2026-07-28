//
//  ActivityIndicator.swift
//  RxSwiftDemo
//
//  Created by Kaiser on 2026/7/28.
//

import Foundation
import RxSwift
import RxCocoa

//加载指示器
private struct ActivityToken<T>: ObservableConvertibleType, Disposable {
    
    private let _source: Observable<T>
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
public class ActivityIndicator: SharedSequenceConvertibleType {
    public typealias Element = Bool
    public typealias SharingStrategy = DriverSharingStrategy

    private let _lock = NSRecursiveLock()
    private let _relay = BehaviorRelay(value: 0)
    private let _loading: SharedSequence<SharingStrategy, Bool>

    public init() {
        _loading = _relay.asDriver()
            .map { $0 > 0 }
            .distinctUntilChanged()
    }

    fileprivate func trackActivityOfObservable<Source: ObservableConvertibleType>(_ source: Source) -> Observable<Source.Element> {
        Observable.using({ () -> ActivityToken<Source.Element> in
            self.increment()
            return ActivityToken(source: source.asObservable(), disposeAction: self.decrement)
        }) { t in
            t.asObservable()
        }
    }

    private func increment() {
        _lock.lock()
        _relay.accept(_relay.value + 1)
        _lock.unlock()
    }

    private func decrement() {
        _lock.lock()
        _relay.accept(_relay.value - 1)
        _lock.unlock()
    }

    public func asSharedSequence() -> SharedSequence<SharingStrategy, Element> {
        _loading
    }
}

public extension ObservableConvertibleType {
    func trackActivity(_ activityIndicator: ActivityIndicator) -> Observable<Element> {
        activityIndicator.trackActivityOfObservable(self)
    }
}
