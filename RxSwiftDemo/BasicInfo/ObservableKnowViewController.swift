//
//  ObservableKnowViewController.swift
//  RxSwiftDemo
//
//  Created by 胡航 on 2026/7/25.
//

import UIKit
import RxSwift

class ObservableKnowViewController: UIViewController {
    
    enum DemoError: Error {
        case numberTooBig
        case unknown
    }
    
    public enum DataError: Error {
        case cantParseJSON
    }
    
    enum CacheError: Error {
        case failedCaching
    }

    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Observable认识"
        
        ObservableCreate()
        singleCreate()
        completableCreate()
        maybeCreate()
    }
    
    //Observable的使用
    func ObservableCreate() {
        //创建序列
        let numbers = Observable.create { observer -> Disposable in
            print("订阅被触发, 开始发生数据")
            
            observer.onNext(0)//发送元素
            observer.onNext(1)
            observer.onNext(2)
            observer.onNext(3)
            observer.onNext(4)
            observer.onNext(5)
            observer.onNext(6)
            
            // 抛出错误，序列终止
            //observer.onError(DemoError.numberTooBig)
            // ⚠️ 下面永远收不到！发送error之后数据流结束
            
            observer.onNext(7)
            observer.onNext(8)
            observer.onNext(9)
            observer.onCompleted()
            
            return Disposables.create {
                print("订阅被释放，执行清理")
            }
        }
        
        // 2. 执行subscribe，才会执行create内部闭包
        let sub = numbers.subscribe { value in
            print("收到值: \(value)")
        } onError: { error in
            print("收到错误: \(error)")
        } onCompleted: {
            print("正常完成")
        }

        // 3. 取消订阅，触发Disposable内的回调
        sub.dispose()
    }
    
    //Single的使用
    //Single 是 Observable 的另外一个版本。不像 Observable 可以发出多个元素，它要么只能发出一个元素，要么产生一个 error 事件。
    func singleCreate() {
        
        func getRepo(_ repo: String) -> Single<[String: Any]> {
            return Single<[String: Any]>.create { single in
                let url = URL(string: "https://api.github.com/repos/\(repo)")!
                let task = URLSession.shared.dataTask(with: url) { data, _, error in
                    
                    if let error = error {
                        single(.failure(error))
                        return
                    }
                    
                    guard let data = data,
                        let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves),
                        let result = json as? [String: Any] else {
                        single(.failure(DataError.cantParseJSON))
                        return
                    }

                    single(.success(result))
                    
                    /*
                     success - 产生一个单独的元素
                     error - 产生一个错误
                     */
                }
                task.resume()
                return Disposables.create { task.cancel() }
            }
        }

        getRepo("ReactiveX/RxSwift")
            .subscribe { json in
                print("请求成功：\(json)")
            } onFailure: { error in
                print("请求失败：\(error)")
            }.disposed(by: disposeBag)
    }
    
    //Completable使用
    //Completable 是 Observable 的另外一个版本。不像 Observable 可以发出多个元素，它要么只能产生一个 completed 事件，要么产生一个 error 事件。
    //Completable 适用于那种你只关心任务是否完成，而不需要在意任务返回值的情况。它和 Observable<Void> 有点相似。
    func completableCreate() {
        
       let completable = Completable.create { completable in
            print("✅ Completable create闭包执行（有人订阅才进来！冷信号）")
            
            // 修改true/false分别测试两种分支
            let success = true
            
            // 模拟耗时操作
            DispatchQueue.global().asyncAfter(deadline: .now()+1) {
                
                guard success else {
                    print("❌ 缓存失败，发送error事件")
                    completable(.error(CacheError.failedCaching))
                    return
                }
                
                print("✅ 缓存成功，发送completed事件")
                completable(.completed)
            }
            
            // 返回清理句柄
            return Disposables.create {
                print("🛑 Completable订阅被销毁，执行清理！")
            }
        }
        
        completable
            .subscribe {
                print("👉 回调：Completed with no error")
            } onError: { error in
                print("👉 回调：Completed with an error: \(error.localizedDescription)")
            }.disposed(by: disposeBag)
    }
    
    
    //Maybe使用
    //Maybe 是 Observable 的另外一个版本。它介于 Single 和 Completable 之间，它要么只能发出一个元素，要么产生一个 completed 事件，要么产生一个 error 事件。
    func maybeCreate() {
        
        let maybeHub = Maybe<String>.create { maybe in
            
            //maybe(.success("RxSwift"))
            //maybe(.error(CacheError.failedCaching))
            maybe(.completed)
            return Disposables.create { }
        }
        
        maybeHub
            .subscribe { element in
                print("Completed with element \(element)")
            } onError: { error in
                print("Completed with an error \(error.localizedDescription)")
            } onCompleted: {
                print("Completed with no element")
            }
            .disposed(by: disposeBag)
    }
    
    
    
    //Driver 不好模拟
    /*
     Driver（司机？） 是一个精心准备的特征序列。它主要是为了简化 UI 层的代码。不过如果你遇到的序列具有以下特征，你也可以使用它：

     不会产生 error 事件
     一定在 MainScheduler 监听（主线程监听）
     共享附加作用
     这些都是驱动 UI 的序列所具有的特征。
     */
}
