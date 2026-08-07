//
//  OtherKnowViewController.swift
//  RxSwiftDemo
//
//  Created by Kaiser on 2026/8/5.
//

import UIKit

class OtherKnowViewController: UIViewController {
    
    // 业务状态
    enum LoginState: Hashable {
        case idle          // 空闲
        case loggingIn     // 登录中
        case success       // 登录成功
        case fail          // 登录失败
    }

    // 触发事件
    enum LoginEvent: Hashable {
        case loginBtnClick   // 点击登录
        case loginSuccess    // 登录接口返回成功
        case loginFail       // 登录接口返回失败
        case reset           // 重置
    }
    
    protocol HTNState {
        associatedtype StateType//就是说你想关联什么样的类型,Int,String,bool,数组,字典等等
        func add(_ item: StateType)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //使用JSONDecoder
        let json = """
            {
        "name": "Durian",
        "points": 600,
        "ability": {
            "mathematics":"excellent",
            "physics": "bad",
            "chemistry": "fine"
        },
        "description": "A fruit with a distinceive scent."
        }
        """.data(using: .utf8)!
        
        struct GroceryProduct: Codable {
            var name: String
            var points: Int?
            var ability: Ability
            var description: String?
            
            struct Ability: Codable {
                var mathematics: Appraise
                var physics: Appraise
                var chemistry: Appraise
            }
            
            enum Appraise: String, Codable {
                case excellent, fine, bad
            }
        }
        
        let decoder = JSONDecoder()
        do {
            let product = try decoder.decode(GroceryProduct.self, from: json)
            print("\(product.ability.mathematics)")
        } catch {
            print("解析错误:\(error)")
        }
        
        //CodingKey协议
        let json2 = """
            {
                "_nick_name": "Tom",
                "point": 600
            }
            """.data(using: .utf8)!
        struct GroceryProduct2: Codable {
            var _nickName: String
            var point: Int
            
            //通过映射的方式实现对不同代码风格的兼容,
//            enum CodingKeys: String, CodingKey {
//                case nickName = "nick_name"
//                case points = "point"
//            }
        }
        let decoder2 = JSONDecoder()
        //convertFromSnakeCase 默认会把_nick_name -> _nickName
        decoder2.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let result = try decoder2.decode(GroceryProduct2.self, from: json2)
            print("===\(result._nickName)--\(result.point)")
        } catch {
            print("解析错误:\(error)")
        }
        
        //判断字符串首个字符是不是_
        let stringKey = "_____hu_hang"
        guard let firstNonUnderscore = stringKey.firstIndex(where: { $0 != "_" }) else {
            fatalError("全是下划线")
        }
        print("---\(firstNonUnderscore)")
        
        print("&&&\(stringKey.endIndex)")
        //先找到整个字符串的最后一个index
        var lastNonUnderscore = stringKey.index(before: stringKey.endIndex)
        print("***\(stringKey[lastNonUnderscore])")
        //从后往前找,找到不是下划线的字符时就跳出while
        while lastNonUnderscore > firstNonUnderscore && stringKey[lastNonUnderscore] == "_" {
            //直接把 i 原地往前移动一位
            stringKey.formIndex(before: &lastNonUnderscore)
        }
        print("处理后的值:\(stringKey[lastNonUnderscore])")

        //请求接口数据
        SMNetWorking<RandomUserResponse>()
            .requestJSON("https://randomuser.me/api/") { data in
                print(data.info.seed)
            }
        
        
        
    }
    
    
    func fxWay() {
        //Swift 泛型
        let dragonsId = [1276,8737,1173]
        let dragonsName = ["red dragon", "blue dragon", "black dragon"]
        func showDragons<T>(dragons: [T]) { //T没有任何约束
            for item in dragons {
                print("\(item)")
            }
        }
        showDragons(dragons: dragonsId)
        showDragons(dragons: dragonsName)
        
        
        // Swift 泛型 + 类型约束
        struct HTNTransition<S: Hashable, E: Hashable> {
            let event: E
            let fromState: S
            let toState: S
            
            init(event: E, fromState: S, toState: S) {
                self.event = event
                self.fromState = fromState
                self.toState = toState
                
                if fromState == toState {
                    print("Two state is same")
                }
            }
        }
        let _ = HTNTransition(event: LoginEvent.reset, fromState: LoginState.idle, toState: LoginState.idle)
        let _ = HTNTransition(event: LoginEvent.reset, fromState: "2", toState: "2")
        
        
        //关联类型
        struct states: HTNState {//非泛型
            // 这个 add 参数是 Int，那协议里的关联类型 StateType 就自动推导为 Int
            func add(_ item: Int) {
                print("关联类型: \(item)")
            }
        }
        let tempStates = states()
        tempStates.add(55)
        
        struct states2<T>: HTNState {//泛型更灵活些
            func add(_ item: T) {
                print("感受泛型的好处:\(item)")
            }
        }
        let tempStates2 = states2<Array<String>>()
        tempStates2.add(["33","44","55"])
        
        //类型擦除
        /*
         当声明一个使用了关联属性的协议对象作为属性时,会出现警告,如何解决:
         1.泛型约束
         2.类型擦除
         */
        struct StateDelegate<T> {
            var state: T
            //var delegate: HTNState
            
            // T 遵守 HTNState
            func testFunc<U: HTNState>(_ value: U) {
                // value.add(xxx)
            }
            
            //类型擦除
            var delegate: AnyHTNState
        }
        
        /*
         类型擦除（Type Eraser）的目的：
         把「带关联类型的协议」包一层普通结构体，抹掉关联类型信息，让你可以存到变量、数组里。
         代价：内部要用 Any，编译期部分类型检查转移到运行时。
         */
        struct AnyHTNState {
            // 闭包：接收Any，内部真正去调用原始对象的add
            private let _add: (Any) -> Void
            
            // 初始化：接收任意一个遵守 HTNState 的对象 T
            init<T: HTNState>(_ base: T) {
                // 保存一个闭包，捕获外部的 base 和 T.StateType
                _add = { item in
                    // item 是 Any，尝试强转成 T.StateType
                    guard let realItem = item as? T.StateType else {
                        // 类型不匹配直接return，啥也不干
                        return
                    }
                    base.add(realItem)
                }
            }
            
            // 对外暴露的add，参数是Any
            func add(_ item: Any) {
                _add(item)
            }
        }
        let s = states2<Int>()
        let erased = AnyHTNState(s)
        erased.add(55)
        
        
        //Where
        func stateFilter<FromState: HTNState, toState: HTNState>(_ from: FromState, _ to: toState) where FromState.StateType == toState.StateType {
            print("where语句是对泛型在应用时的一种约束")
        }
        let s2 = states2<Int>()
        let s3 = states2<Int>()
        stateFilter(s2, s3)
        
        
        //泛型和Any类型 区别:泛型灵活安全 Any类型会避开类型检查,不安全
        //迭代器
        class stateItr: IteratorProtocol {
            var num: Int = 1
            func next() -> Int? {
                num += 4
                return num
            }
        }
        
        func findNext<I: IteratorProtocol>(elm: I) -> AnyIterator<I.Element> where I.Element == Int {
            var l = elm
            print("\(l.next() ?? 0)")
            return AnyIterator { l.next()}
        }
        
        let num = findNext(elm: findNext(elm: findNext(elm: stateItr())))
        print("\(num)")
        
        /*
         
         @inlinable public func map<T, E>(_ transform: (Character) throws(E) -> T) throws(E) -> [T] where E : Error
         
         @inlinable
         允许跨模块编译器拿到函数体，可以做内联、泛型特化优化；编辑器看不到实现，编译器看得到
         
         <T, E>
         T: map 转换之后输出的元素类型  例："abc".map { $0.isUppercase } → T = Bool，最终返回 [Bool]
         E: 代表transform 闭包可能抛出的错误类型。
         where E : Error：约束，E 必须遵守 Error 协议。
         
         transform: (Character) throws(E) -> T
         transform：变换闭包
         入参：Character（因为这个 map 是字符串的，Element 是 Character）
         throws(E)：这个闭包可能抛出类型为 E 的错误
         返回：T，转换后的单个结果。
         
         throws(E) -> [T]
         map 函数本身，会向外抛出 E 类型错误
         返回值 [T]：转换完成的数组
         
         一旦抛出错误，函数直接退出，不会返回 [T]
         */
        let cast = ["Vivien", "Marlon", "Kim", "Karl"]
        let _ = cast.map { $0.lowercased() }
        
        //map源码理解
        do {
            let source = MyArray(["1","2","3","4"])
            let res = try source.myMap { str in
                guard let num = Int(str) else { throw TestErr.invalidNumber }
                return num
            }
            print("正常结果: \(res)")
        } catch {
            print("错误: \(error)")
        }
        
        //compactMap
        let possibleNumbers = ["1","2","three","//4//","5"]
        let mapped:[Int?] = possibleNumbers.map { str in Int(str) }
        print("map: \(mapped)")
        
        let compactMaped = possibleNumbers.compactMap { str in Int(str) }
        print("compactMap: \(compactMaped)")
        
        //Reduce
        let numbers = [1,2,3,114]
        let numberSum = numbers.reduce(1) { x, y in x + y }
        print("累加器: \(numberSum)")
        
        //Array
        var nums = [Int]()
        var mArray = nums + [2,3,5] + [5,9]
        var animals: [String] = ["dragon","cat","mice","dog"]
        
        animals.append("bird")
        print("\(animals)")
        animals += ["ant"]
        print("\(animals)")
        
        let firstItem = mArray[0]
        print("\(firstItem)")
        animals[0] = "huhang"
        print("\(animals)")
        animals[2...4] = ["black dragon"]
        print("\(animals)")
        animals.insert("lxb", at: animals.count)
        print("\(animals)")
        
        let mapleSyrup = animals.remove(at: animals.count-1)
        print("\(mapleSyrup)--\(animals)")
        
        print("\(animals)")
        for (index,animal) in animals.enumerated() {
            print("animal \(String(index+1)): \(animal)")
        }
        
        //弱引用的Swift数组
        //数组默认强引用
        let strongArr = NSPointerArray.strongObjects()
        let weakArr = NSPointerArray.weakObjects()
        //字典弱引用使用:NSMapTable
        //Set弱引用使用:NSHashTable
        
        //Dictionary
        var strs = [Int: String]()
        var colors: [String: String] = ["red": "#e83f45","yellow": "#ffe651"]
        strs[16] = "sixteen"
        print("\(strs)")
        
        if let oldValue = colors.updateValue("#e83f47", forKey: "yellow") {
            print("The old value for DUB was \(oldValue)")
        }
        
        for (color, value) in colors {
            print("\(color): \(value)")
        }
        
        let newColorValue = colors.map { "hex:\($0.value)" }
        print("\(newColorValue)")
        
        //修改value值后,返回新的字典
        let newColors = colors.mapValues { "hex:\($0)" }
        print("\(newColors)")
    }
    
}
