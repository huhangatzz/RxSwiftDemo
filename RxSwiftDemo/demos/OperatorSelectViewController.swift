//
//  OperatorSelectViewController.swift
//  RxSwiftDemo
//
//  Created by Kaiser on 2026/7/27.
//

import UIKit
import RxSwift
import RxCocoa

class OperatorSelectViewController: UIViewController {

    let disposeBag = DisposeBag()
    
    enum TestError: Error {
        case test
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("⚠️catch")
        catchTest()
        print("\n ⚠️catchAndReturn")
        catchAndReturnTest()
        print("\n ⚠️combineLatest")
        combineLatestTest()
        print("\n ⚠️Zip")
        zipTest()
        print("\n ⚠️concat")
        concatTest()
        print("\n ⚠️startWith")
        startWithTest()
        print("\n ⚠️merge")
        mergeTest()
        print("\n ⚠️concatMap")
        concatMapTest()
        //print("\n ⚠️connect")
        //connectTest()
        print("\n ⚠️debug")
        debugTest()
        print("\n ⚠️distinctUntilChanged")
        distinctUntilChangedTest()
        print("\n ⚠️elementAt")
        elementAtTest()
        print("\n ⚠️filter")
        filterTest()
        print("\n ⚠️flatMap")
        flatMapTest()
        print("\n ⚠️flatMapLatest")
        flatMapLatestTest()
        print("\n ⚠️map")
        mapTest()
//        print("\n ⚠️publish")
//        publishTest()
//        print("\n ⚠️replay")
//        replayTest()
        print("\n ⚠️retry演示1")
        retryTest()
        print("\n retry演示2")
        retryTest2()
        print("\n ⚠️scan")
        scanTest()
        print("\n ⚠️skip")
        skipTest()
        print("\n ⚠️skipUntil")
        skipUntilTest()
        print("\n ⚠️skipWhile")
        skipWhileTest()
        print("\n ⚠️take")
        takeTest()
        print("\n ⚠️takeLast")
        takeLastTest()
        print("\n ⚠️takeUntil")
        takeUntilTest()
        print("\n ⚠️takeWhile")
        takeWhileTest()
        print("\n ⚠️withLatestFrom演示1")
        withLatestFromTest1()
        print("\n withLatestFrom演示2")
        withLatestFromTest2()
    }
    
    //catchError过期了,请使用catch 操作符将会拦截一个 error 事件，将它替换成其他的元素或者一组元素，然后传递给观察者。这样可以使得 Observable 正常结束，或者根本都不需要结束。
    func catchTest() {
        
        let sequenceThatFails = PublishSubject<String>()
        let recoverySequence = PublishSubject<String>()
        
        sequenceThatFails
            .catch {
                print("Error:", $0)
                return recoverySequence
            }
            .subscribe { print($0) }
            .disposed(by: disposeBag)
        
        sequenceThatFails.onNext("😬")
        sequenceThatFails.onNext("😨")
        sequenceThatFails.onNext("😡")
        sequenceThatFails.onNext("🔴")
        sequenceThatFails.onError(TestError.test)
        
        recoverySequence.onNext("😊")
    }
    
    //catchErrorJustReturn过期了,请使用catchAndReturn 操作符会将error 事件替换成其他的一个元素，然后结束该序列。
    func catchAndReturnTest() {
        let sequenceThatFails = PublishSubject<String>()
        sequenceThatFails
            .catchAndReturn("😊")
            .subscribe { print($0) }
            .disposed(by: disposeBag)
        
        sequenceThatFails.onNext("😬")
        sequenceThatFails.onNext("😨")
        sequenceThatFails.onNext("😡")
        sequenceThatFails.onNext("🔴")
        sequenceThatFails.onError(TestError.test)
        
        sequenceThatFails.onNext("胡航最帅")
    }
    
    //combineLatest 操作符将多个 Observables 中最新的元素通过一个函数组合起来，然后将这个组合的结果发出来。这些源 Observables 中任何一个发出一个元素，他都会发出一个元素（前提是，这些 Observables 曾经都发出过元素）。
    func combineLatestTest() {
        let first = PublishSubject<String>()
        let second = PublishSubject<String>()
        
        Observable
            .combineLatest(first, second) { $0 + $1}
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        first.onNext("1")
        second.onNext("A")
        
        first.onNext("2")
        first.onNext("3")
        first.onNext("4")
        second.onNext("B")
        second.onNext("C")
        second.onNext("D")
    }
    
    //zip 通过一个函数将多个 Observables 的元素组合起来，然后将每一个组合的结果发出来
    //zip 操作符将多个(最多不超过8个) Observables 的元素通过一个函数组合起来，然后将这个组合的结果发出来。它会严格的按照序列的索引数进行组合。例如，返回的 Observable 的第一个元素，是由每一个源 Observables 的第一个元素组合出来的。它的第二个元素 ，是由每一个源 Observables 的第二个元素组合出来的。它的第三个元素 ，是由每一个源 Observables 的第三个元素组合出来的，以此类推。它的元素数量等于源 Observables 中元素数量最少的那个。
    func zipTest() {
        let first = PublishSubject<String>()
        let second = PublishSubject<String>()
        
        Observable.zip(first, second) { $0 + $1}
            .subscribe(onNext: { print($0)})
            .disposed(by: disposeBag)
        
        first.onNext("1")
        second.onNext("A")
        
        first.onNext("2")
        second.onNext("B")
        
        second.onNext("C")
        second.onNext("D")
        first.onNext("3")
        first.onNext("4")
    }
    
    /*
    concat 操作符将多个 Observables 按顺序串联起来，当前一个 Observable 元素发送完毕后，后一个 Observable 才可以开始发出元素。
    concat 将等待前一个 Observable 产生完成事件后，才对后一个 Observable 进行订阅。如果后一个是“热” Observable ，在它前一个 Observable 产生完成事件前，所产生的元素将不会被发送出来。
    startWith 和它十分相似。但是 startWith 不是在后面添加元素，而是在前面插入元素。
    
    merge 和它也是十分相似。merge 并不是将多个 Observables 按顺序串联起来，而是将他们合并到一起，不需要 Observables 按先后顺序发出元素。
     */
    func concatTest() {
        let subject1 = BehaviorSubject(value: "🍎")
        let subject2 = BehaviorSubject(value: "🐶")

        let subject = BehaviorSubject(value: subject1)

        subject
            .asObservable()
            .concat()
            .subscribe { print($0) }
            .disposed(by: disposeBag)

        subject1.onNext("🍐")
        subject1.onNext("🍊")

        subject.onNext(subject2)

        subject2.onNext("I would be ignored")
        subject2.onNext("🐱")
        subject2.onNext("胡航最帅")
        
        //需要等待subject1这个完成
        subject1.onCompleted()

        subject2.onNext("🐭")
    }
    
    //startWith 操作符会在 Observable 头部插入一些元素。
    func startWithTest() {
        Observable.of("🐶", "🐱", "🐭", "🐹")
            .startWith("1")
            .startWith("2")
            .startWith("3", "🅰️", "🅱️")
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    
    //merge 通过使用 merge 操作符你可以将多个 Observables 合并成一个，当某一个 Observable 发出一个元素时，他就将这个元素发出。
    //如果，某一个 Observable 发出一个 onError 事件，那么被合并的 Observable 也会将它发出，并且立即终止序列。
    func mergeTest() {
        let subject1 = PublishSubject<String>()
        let subject2 = PublishSubject<String>()

        Observable.of(subject1, subject2)
            .merge()
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)

        subject1.onNext("🅰️")

        subject1.onNext("🅱️")

        subject2.onNext("①")

        subject2.onNext("②")

        subject1.onNext("🆎")

        subject2.onNext("③")
    }
    
    //concatMap 操作符将源 Observable 的每一个元素应用一个转换方法，将他们转换成 Observables。然后让这些 Observables 按顺序的发出元素，当前一个 Observable 元素发送完毕后，后一个 Observable 才可以开始发出元素。等待前一个 Observable 产生完成事件后，才对后一个 Observable 进行订阅。
    func concatMapTest() {
        let subject1 = BehaviorSubject(value: "🍎")
        let subject2 = BehaviorSubject(value: "🐶")

        let subject = BehaviorSubject(value: subject1)

        subject.asObservable()
                .concatMap { $0 }
                .subscribe { print($0) }
                .disposed(by: disposeBag)

        subject1.onNext("🍐")
        subject1.onNext("🍊")

        subject.onNext(subject2)

        subject2.onNext("I would be ignored")
        subject2.onNext("🐱")

        subject1.onCompleted()

        subject2.onNext("🐭")

    }
    
    //connect 通知 ConnectableObservable 可以开始发出元素了, ConnectableObservable 和普通的 Observable 十分相似，不过在被订阅后不会发出元素，直到 connect 操作符被应用为止。这样一来你可以等所有观察者全部订阅完成后，才发出元素。
    func connectTest() {
        let intSequence = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .publish()

        _ = intSequence
            .subscribe(onNext: { print("Subscription 1:, Event: \($0)") })

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            _ = intSequence.connect()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
          _ = intSequence
              .subscribe(onNext: { print("Subscription 2:, Event: \($0)") })
        }

    }
    
    //debounce 操作符将发出这种元素，在 Observable 产生这种元素后，一段时间内没有新元素产生。
    
    //debug 打印所有的订阅，事件以及销毁信息
    func debugTest() {
        let sequence = Observable<String>.create { observer in
            observer.onNext("🍎")
            observer.onNext("🍐")
            observer.onCompleted()
            return Disposables.create()
        }

        sequence
            .debug("Fruit")
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    //deferred 直到订阅发生，才创建 Observable，并且为每位订阅者创建全新的 Observable
    //deferred 操作符将等待观察者订阅它，才创建一个 Observable，它会通过一个构建函数为每一位订阅者创建新的 Observable。看上去每位订阅者都是对同一个 Observable 产生订阅，实际上它们都获得了独立的序列。在一些情况下，直到订阅时才创建 Observable 是可以保证拿到的数据都是最新的。
    
    //delaySubscription 操作符将在经过所设定的时间后，才对 Observable 进行订阅操作。
    
    //distinctUntilChanged 操作符将阻止 Observable 发出相同的元素。如果后一个元素和前一个元素是相同的，那么这个元素将不会被发出来。如果后一个元素和前一个元素不相同，那么这个元素才会被发出来。
    func distinctUntilChangedTest() {
        Observable.of("🐱", "🐷", "🐱", "🐱", "🐱", "🐵", "🐱")
            .distinctUntilChanged()
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    
    //do 当 Observable 产生某些事件时，执行某个操作,当 Observable 的某些事件产生时，你可以使用 do 操作符来注册一些回调操作。这些回调会被单独调用，它们会和 Observable 原本的回调分离。
    
    //elementAt 只发出 Observable 中的第 n 个元素,
    //elementAt 操作符将拉取 Observable 序列中指定索引数的元素，然后将它作为唯一的元素发出。
    func elementAtTest() {
        Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
            .element(at: 3)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    
    /*
    empty 操作符将创建一个 Observable，这个 Observable 只有一个完成事件。
    let id = Observable<Int>.empty()
    它相当于：let id = Observable<Int>.create { observer in
                observer.onCompleted()
             return Disposables.create()
     }
    */
    
    /*
     error

     error 操作符将创建一个 Observable，这个 Observable 只会产生一个 error 事件。
     
     创建一个只有 error 事件的 Observable：
     let error: Error = ...
     let id = Observable<Int>.error(error)
     
     它相当于：
     let error: Error = ...
     let id = Observable<Int>.create { observer in
         observer.onError(error)
         return Disposables.create()
     }
     */
    
    //filter 仅仅发出 Observable 中通过判定的元素
    //filter 操作符将通过你提供的判定方法过滤一个 Observable。
    func filterTest() {
        Observable.of(2, 30, 22, 5, 60, 1)
                  .filter { $0 > 10 }
                  .subscribe(onNext: { print($0) })
                  .disposed(by: disposeBag)
    }
    
    //flatMap 将 Observable 的元素转换成其他的 Observable，然后将这些 Observables 合并
    //flatMap 操作符将源 Observable 的每一个元素应用一个转换方法，将他们转换成 Observables。 然后将这些 Observables 的元素合并之后再发送出来。
    //这个操作符是非常有用的，例如，当 Observable 的元素本身拥有其他的 Observable 时，你可以将所有子 Observables 的元素发送出来。
    func flatMapTest() {
        let first = BehaviorSubject(value: "👦🏻")
        let second = BehaviorSubject(value: "🅰️")
        let subject = BehaviorSubject(value: first)

        subject.asObservable()
                .flatMap { $0 }
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag)

        first.onNext("🐱")
        subject.onNext(second)
        second.onNext("🅱️")
        first.onNext("🐶")
    }
    
    //flatMapLatest 将 Observable 的元素转换成其他的 Observable，然后取这些 Observables 中最新的一个
    //flatMapLatest 操作符将源 Observable 的每一个元素应用一个转换方法，将他们转换成 Observables。一旦转换出一个新的 Observable，就只发出它的元素，旧的 Observables 的元素将被忽略掉。
    func flatMapLatestTest() {
        let first = BehaviorSubject(value: "👦🏻")
        let second = BehaviorSubject(value: "🅰️")
        let subject = BehaviorSubject(value: first)

        subject.asObservable()
                .flatMapLatest { $0 }
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag)

        first.onNext("🐱")
        subject.onNext(second)
        second.onNext("🅱️")
        first.onNext("🐶")
        
        /*
         👦🏻
         🐱
         🅰️
         🅱️
         */
    }
    
    /*
     from 将其他类型或者数据结构转换为 Observable
     当你在使用 Observable 时，如果能够直接将其他类型转换为 Observable，这将是非常省事的。from 操作符就提供了这种功能。
     将一个数组转换为 Observable：
      let numbers = Observable.from([0, 1, 2])
     
     它相当于：
     let numbers = Observable<Int>.create { observer in
         observer.onNext(0)
         observer.onNext(1)
         observer.onNext(2)
         observer.onCompleted()
         return Disposables.create()
     }
     
     将一个可选值转换为 Observable：
     let optional: Int? = 1
     let value = Observable.from(optional: optional)
     它相当于：
     let optional: Int? = 1
     let value = Observable<Int>.create { observer in
         if let element = optional {
             observer.onNext(element)
         }
         observer.onCompleted()
         return Disposables.create()
     }
     */
    
    /*
     groupBy 将源 Observable 分解为多个子 Observable，并且每个子 Observable 将源 Observable 中“相似”的元素发送出来
     groupBy 操作符将源 Observable 分解为多个子 Observable，然后将这些子 Observable 发送出来。

     它会将元素通过某个键进行分组，然后将分组后的元素序列以 Observable 的形态发送出来。
     */
    
    /*
     ignoreElements 忽略掉所有的元素，只发出 error 或 completed 事件
     ignoreElements 操作符将阻止 Observable 发出 next 事件，但是允许他发出 error 或 completed 事件。

     如果你并不关心 Observable 的任何元素，你只想知道 Observable 在什么时候终止，那就可以使用 ignoreElements 操作符。
     */
    
    /*
     interval
     创建一个 Observable 每隔一段时间，发出一个索引数
     interval 操作符将创建一个 Observable，它每隔一段设定的时间，发出一个索引数的元素。它将发出无数个元素。
     */
    
    /*
     just
     创建 Observable 发出唯一的一个元素
     just 操作符将某一个元素转换为 Observable。
     一个序列只有唯一的元素 0：let id = Observable.just(0)
     它相当于：
     let id = Observable<Int>.create { observer in
         observer.onNext(0)
         observer.onCompleted()
         return Disposables.create()
     }
     */
    
    //map 通过一个转换函数，将 Observable 的每个元素转换一遍
    //map 操作符将源 Observable 的每个元素应用你提供的转换方法，然后返回含有转换结果的 Observable。
    func mapTest() {
        Observable.of(1, 2, 3)
            .map { $0 * 10 }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    
    /*
     materialize 将序列产生的事件，转换成元素
     通常，一个有限的 Observable 将产生零个或者多个 onNext 事件，然后产生一个 onCompleted 或者 onError 事件。

     materialize 操作符将 Observable 产生的这些事件全部转换成元素，然后发送出来。
     */
    
    /*
     never 创建一个永远不会发出元素的 Observable
     never 操作符将创建一个 Observable，这个 Observable 不会产生任何事件。
     创建一个不会产生任何事件的 Observable：let id = Observable<Int>.never()
     它相当于：
     let id = Observable<Int>.create { observer in
         return Disposables.create()
     }
     */
    
    /*
     observeOn 指定 Observable 在那个 Scheduler 发出通知
     ReactiveX 使用 Scheduler 来让 Observable 支持多线程。你可以使用 observeOn 操作符，来指示 Observable 在哪个 Scheduler 发出通知。
     
     subscribeOn 操作符非常相似。它指示 Observable 在哪个 Scheduler 发出执行。

     默认情况下，Observable 创建，应用操作符以及发出通知都会在 Subscribe 方法调用的 Scheduler 执行。subscribeOn 操作符将改变这种行为，它会指定一个不同的 Scheduler 来让 Observable 执行，observeOn 操作符将指定一个不同的 Scheduler 来让 Observable 通知观察者。

     如上图所示，subscribeOn 操作符指定 Observable 在那个 Scheduler 开始执行，无论它处于链的那个位置。 另一方面 observeOn 将决定后面的方法在哪个 Scheduler 运行。因此，你可能会多次调用 observeOn 来决定某些操作符在哪个线程运行。
     */
    
    //publish 将 Observable 转换为可被连接的 Observabl
    //publish 会将 Observable 转换为可被连接的 Observable。可被连接的 Observable 和普通的 Observable 十分相似，不过在被订阅后不会发出元素，直到 connect 操作符被应用为止。这样一来你可以控制 Observable 在什么时候开始发出元素。
    func publishTest() {
        let intSequence = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .publish()

        _ = intSequence
            .subscribe(onNext: { print("Subscription 1:, Event: \($0)") })

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            _ = intSequence.connect()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
          _ = intSequence
              .subscribe(onNext: { print("Subscription 2:, Event: \($0)") })
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
          _ = intSequence
              .subscribe(onNext: { print("Subscription 3:, Event: \($0)") })
        }
    }
    
    /*
     reduce 持续的将 Observable 的每一个元素应用一个函数，然后发出最终结果
     reduce 操作符将对第一个元素应用一个函数。然后，将结果作为参数填入到第二个元素的应用函数中。以此类推，直到遍历完全部的元素后发出最终结果。

     这种操作符在其他地方有时候被称作是 accumulator，aggregate，compress，fold 或者 inject。
     */
    func reduceTest() {
        Observable.of(10, 100, 1000)
            .reduce(1, accumulator: +)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    
    /*
     refCount 将可被连接的 Observable 转换为普通 Observable
     可被连接的 Observable 和普通的 Observable 十分相似，不过在被订阅后不会发出元素，直到 connect 操作符被应用为止。这样一来你可以控制 Observable 在什么时候开始发出元素。

     refCount 操作符将自动连接和断开可被连接的 Observable。它将可被连接的 Observable 转换为普通 Observable。当第一个观察者对它订阅时，那么底层的 Observable 将被连接。当最后一个观察者离开时，那么底层的 Observable 将被断开连接。
     */
    
    /*
     repeatElement 创建重复发出某个元素的 Observable
     repeatElement 操作符将创建一个 Observable，这个 Observable 将无止尽地发出同一个元素。
     创建重复发出 0 的 Observable

     let id = Observable.repeatElement(0)
     它相当于：

     let id = Observable<Int>.create { observer in
         observer.onNext(0)
         observer.onNext(0)
         observer.onNext(0)
         observer.onNext(0)
         ... // 无数次
         return Disposables.create()
     }
     */
    
    /*
     replay 确保观察者接收到同样的序列，即使是在 Observable 发出元素后才订阅
     
     可被连接的 Observable 和普通的 Observable 十分相似，不过在被订阅后不会发出元素，直到 connect 操作符被应用为止。这样一来你可以控制 Observable 在什么时候开始发出元素。

     replay 操作符将 Observable 转换为可被连接的 Observable，并且这个可被连接的 Observable 将缓存最新的 n 个元素。当有新的观察者对它进行订阅时，它就把这些被缓存的元素发送给观察者。
     */
    func replayTest() {
        let intSequence = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .replay(5)

        _ = intSequence
            .subscribe(onNext: { print("Subscription 1:, Event: \($0)") })

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            _ = intSequence.connect()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
          _ = intSequence
              .subscribe(onNext: { print("Subscription 2:, Event: \($0)") })
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
          _ = intSequence
              .subscribe(onNext: { print("Subscription 3:, Event: \($0)") })
        }
    }
    
    /*
     retry 如果源 Observable 产生一个错误事件，重新对它进行订阅，希望它不会再次产生错误
     
     retry 操作符将不会将 error 事件，传递给观察者，然而，它会从新订阅源 Observable，给这个 Observable 一个重试的机会，让它有机会不产生 error 事件。retry 总是对观察者发出 next 事件，即便源序列产生了一个 error 事件，所以这样可能会产生重复的元素
     */
    func retryTest() {
        var count = 1

        let sequenceThatErrors = Observable<String>.create { observer in
            observer.onNext("🍎")
            observer.onNext("🍐")
            observer.onNext("🍊")

            if count == 1 {
                observer.onError(TestError.test)
                print("Error encountered")
                count += 1
            }

            observer.onNext("🐶")
            observer.onNext("🐱")
            observer.onNext("🐭")
            observer.onCompleted()

            return Disposables.create()
        }

        sequenceThatErrors
            .retry()
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    
    func retryTest2() {
        var count = 1

        let sequenceThatErrors = Observable<String>.create { observer in
            observer.onNext("🍎")
            observer.onNext("🍐")
            observer.onNext("🍊")

            if count < 5 {
                observer.onError(TestError.test)
                print("Error encountered")
                count += 1
            }

            observer.onNext("🐶")
            observer.onNext("🐱")
            observer.onNext("🐭")
            observer.onCompleted()

            return Disposables.create()
        }

        sequenceThatErrors
            .retry(3)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    
    /*
     sample 不定期的对 Observable 取样
     
     sample 操作符将不定期的对源 Observable 进行取样操作。通过第二个 Observable 来控制取样时机。一旦第二个 Observable 发出一个元素，就从源 Observable 中取出最后产生的元素。
     */
    
    /*
     scan 持续的将 Observable 的每一个元素应用一个函数，然后发出每一次函数返回的结果
     
     scan 操作符将对第一个元素应用一个函数，将结果作为第一个元素发出。然后，将结果作为参数填入到第二个元素的应用函数中，创建第二个元素。以此类推，直到遍历完全部的元素。

     这种操作符在其他地方有时候被称作是 accumulator。
     */
    func scanTest() {
        Observable.of(10, 100, 1000)
            .scan(5) { aggregateValue, newValue in
                aggregateValue + newValue
            }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    
    /*
     shareReplay 使观察者共享 Observable，观察者会立即收到最新的元素，即使这些元素是在订阅前产生的
     
     shareReplay 操作符将使得观察者共享源 Observable，并且缓存最新的 n 个元素，将这些元素直接发送给新的观察者。
     */
    
    /*
     single 限制 Observable 只有一个元素，否出发出一个 error 事件
     
     single 操作符将限制 Observable 只产生一个元素。如果 Observable 只有一个元素，它将镜像这个 Observable 。如果 Observable 没有元素或者元素数量大于一，它将产生一个 error 事件。
     */
    
    /*
     skip 跳过 Observable 中头 n 个元素
     skip 操作符可以让你跳过 Observable 中头 n 个元素，只关注后面的元素。
     */
    func skipTest() {
        Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
            .skip(2)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    
    /*
     skipUntil 跳过 Observable 中头几个元素，直到另一个 Observable 发出一个元素
     skipUntil 操作符可以让你忽略源 Observable 中头几个元素，直到另一个 Observable 发出一个元素后，它才镜像源 Observable。
     */
    func skipUntilTest() {
        let sourceSequence = PublishSubject<String>()
        let referenceSequence = PublishSubject<String>()

        sourceSequence
            .skip(until: referenceSequence)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)

        sourceSequence.onNext("🐱")
        sourceSequence.onNext("🐰")
        sourceSequence.onNext("🐶")

        referenceSequence.onNext("🔴")

        sourceSequence.onNext("🐸")
        sourceSequence.onNext("🐷")
        sourceSequence.onNext("🐵")
    }
    
    /*
     skipWhile(过期了,请使用skip) 跳过 Observable 中头几个元素，直到元素的判定为否
     skipWhile 操作符可以让你忽略源 Observable 中头几个元素，直到元素的判定为否后，它才镜像源 Observable
     */
    func skipWhileTest() {
        Observable.of(1, 2, 3, 4, 3, 2, 1)
            .skip { $0 < 4 }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    
    /*
     take 仅仅从 Observable 中发出头 n 个元素
     通过 take 操作符你可以只发出头 n 个元素。并且忽略掉后面的元素，直接结束序列。
     */
    func takeTest() {
        Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
            .take(3)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    
    /*
     takeLast 仅仅从 Observable 中发出尾部 n 个元素
     通过 takeLast 操作符你可以只发出尾部 n 个元素。并且忽略掉前面的元素。
     */
    func takeLastTest() {
        Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
            .takeLast(3)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    
    /*
     takeUntil 忽略掉在第二个 Observable 产生事件后发出的那部分元素
     takeUntil 操作符将镜像源 Observable，它同时观测第二个 Observable。一旦第二个 Observable 发出一个元素或者产生一个终止事件，那个镜像的 Observable 将立即终止。
     */
    func takeUntilTest() {
        let sourceSequence = PublishSubject<String>()
        let referenceSequence = PublishSubject<String>()

        sourceSequence
            .take(until: referenceSequence)
            .subscribe { print($0) }
            .disposed(by: disposeBag)

        sourceSequence.onNext("🐱")
        sourceSequence.onNext("🐰")
        sourceSequence.onNext("🐶")

        referenceSequence.onNext("🔴")

        sourceSequence.onNext("🐸")
        sourceSequence.onNext("🐷")
        sourceSequence.onNext("🐵")
    }
    
    /*
     takeWhile 镜像一个 Observable 直到某个元素的判定为 false
     takeWhile 操作符将镜像源 Observable 直到某个元素的判定为 false。此时，这个镜像的 Observable 将立即终止。
     */
    func takeWhileTest() {
        Observable.of(1, 2, 3, 4, 3, 2, 1)
            .take(while: { $0 < 4 } )
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    
    /*
     timeout 如果源 Observable 在规定时间内没有发出任何元素，就产生一个超时的 error 事件
     如果 Observable 在一段时间内没有产生元素，timeout 操作符将使它发出一个 error 事件。
     */
    
    /*
     timer 创建一个 Observable 在一段延时后，产生唯一的一个元素
     timer 操作符将创建一个 Observable，它在经过设定的一段时间后，产生唯一的一个元素。

     这里存在其他版本的 timer 操作符。
     
     创建一个 Observable 在一段延时后，每隔一段时间产生一个元素
     
     public static func timer(
       _ dueTime: RxTimeInterval,  // 初始延时
       period: RxTimeInterval?,    // 时间间隔
       scheduler: SchedulerType
       ) -> Observable<E>
     */
    
    /*
     using 创建一个可被清除的资源，它和 Observable 具有相同的寿命
     通过使用 using 操作符创建 Observable 时，同时创建一个可被清除的资源，一旦 Observable 终止了，那么这个资源就会被清除掉了。
     */
    
    /*
     window 将 Observable 分解为多个子 Observable，周期性的将子 Observable 发出来
     window 操作符和 buffer 十分相似，buffer 周期性的将缓存的元素集合发送出来，而 window 周期性的将元素集合以 Observable 的形态发送出来。

     buffer 要等到元素搜集完毕后，才会发出元素序列。而 window 可以实时发出元素序列。
     */
    
    /*
     withLatestFrom 将两个 Observables 最新的元素通过一个函数组合起来，当第一个 Observable 发出一个元素，就将组合后的元素发送出来
     withLatestFrom 操作符将两个 Observables 中最新的元素通过一个函数组合起来，然后将这个组合的结果发出来。当第一个 Observable 发出一个元素时，就立即取出第二个 Observable 中最新的元素，通过一个组合函数将两个最新的元素合并后发送出去。
     */
    
    //当第一个 Observable 发出一个元素时，就立即取出第二个 Observable 中最新的元素，然后把第二个 Observable 中最新的元素发送出去。
    func withLatestFromTest1() {
        let firstSubject = PublishSubject<String>()
        let secondSubject = PublishSubject<String>()

        firstSubject
             .withLatestFrom(secondSubject)
             .subscribe(onNext: { print($0) })
             .disposed(by: disposeBag)

        firstSubject.onNext("🅰️")
        firstSubject.onNext("🅱️")
        secondSubject.onNext("1")
        secondSubject.onNext("2")
        firstSubject.onNext("🆎")
    }
    
    //当第一个 Observable 发出一个元素时，就立即取出第二个 Observable 中最新的元素，将第一个 Observable 中最新的元素 first 和第二个 Observable 中最新的元素second组合，然后把组合结果 first+second发送出去。
    func withLatestFromTest2() {
        let firstSubject = PublishSubject<String>()
        let secondSubject = PublishSubject<String>()

        firstSubject
             .withLatestFrom(secondSubject) {
                  (first, second) in
                  return first + second
             }
             .subscribe(onNext: { print($0) })
             .disposed(by: disposeBag)

        firstSubject.onNext("🅰️")
        firstSubject.onNext("🅱️")
        secondSubject.onNext("1")
        secondSubject.onNext("2")
        firstSubject.onNext("🆎")
    }
}

