//
//  MyMapStudy.swift
//  RxSwiftDemo
//
//  Created by Kaiser on 2026/8/6.
//

import Foundation

// MARK: 1. 基础迭代器协议（对标标准库 IteratorProtocol）
public protocol MyIteratorProtocol {
    associatedtype Element
    mutating func next() -> Element?
}

// MARK: 2. 基础序列协议（对标标准 Sequence）
public protocol MySequence {
    associatedtype Element
    associatedtype Iterator: MyIteratorProtocol where Iterator.Element == Element
    func makeIterator() -> Iterator
    var underestimatedCount: Int { get }
}

// Sequence 默认 underestimatedCount 实现（标准库原版）
extension MySequence {
    var underestimatedCount: Int { 0 }
}

// MARK: 3. 简化复刻 ContiguousArray（带 reserveCapacity、append，对应源码逻辑）
struct MyContiguousArray<Element> {
    private var _storage: UnsafeMutableBufferPointer<Element>?
    var count: Int = 0
    var capacity: Int { _storage?.count ?? 0 }
    
    init() {
        _storage = nil
        count = 0
    }
    
    // 复刻标准库 reserveCapacity 逻辑
    mutating func reserveCapacity(_ minimumCapacity: Int) {
        if capacity >= minimumCapacity { return }
        // 分配更大内存缓冲区
        let newCap = Swift.max(minimumCapacity, capacity * 2)
        let newBuf = UnsafeMutableBufferPointer<Element>.allocate(capacity: newCap)
        // 拷贝旧元素
        if let old = _storage, count > 0 {
            for i in 0..<count {
                newBuf[i] = old[i]
            }
            old.deallocate()
        }
        _storage = newBuf
    }
    
    // append 完整复刻标准库逻辑
    mutating func append(_ element: Element) {
        if count >= capacity {
            reserveCapacity(count + 1)
        }
        guard let buf = _storage else {
            reserveCapacity(4)
            _storage![0] = element
            count = 1
            return
        }
        buf[count] = element
        count += 1
    }
    
    // 转为普通数组（对应 map 最后 return Array(result)）
    func toArray() -> [Element] {
        guard let buf = _storage, count > 0 else { return [] }
        var arr = [Element]()
        arr.reserveCapacity(count)
        for i in 0..<count {
            arr.append(buf[i])
        }
        return arr
    }
}

// MARK: 4. 核心：复刻标准库 map 完整源码（来自 Sequence.swift）
extension MySequence {
    /// 1:1 复刻标准库 @export(implementation) map<T,E>
    func myMap<T, E>(
        _ transform: (Element) throws(E) -> T
    ) throws(E) -> [T] where E: Error {
        // 第一行：获取低估容量
        let initialCapacity = underestimatedCount
        // 创建高性能中间容器
        var result = MyContiguousArray<T>()
        // 预分配内存（你之前关注的代码块）
        result.reserveCapacity(initialCapacity)
        
        // 获取迭代器 self.makeIterator()
        var iterator = self.makeIterator()
        
        // 第一段循环：无需nil判断，underestimatedCount保证一定有值
        for _ in 0..<initialCapacity {
            result.append(try transform(iterator.next()!))
        }
        // 第二段循环：兜底处理剩余元素
        while let element = iterator.next() {
            result.append(try transform(element))
        }
        // 转普通数组返回
        return result.toArray()
    }
}

// MARK: 5. 测试用序列：自定义数组容器，遵守 MySequence 用于调试
struct MyArray<Element>: MySequence {
    private var data: [Element]
    
    init(_ elements: [Element]) {
        data = elements
    }
    
    // 迭代器实现
    struct Iter: MyIteratorProtocol {
        private var idx = 0
        private let data: [Element]
        init(_ arr: [Element]) { data = arr }
        mutating func next() -> Element? { //修改外部变量增加mutating
            guard idx < data.count else { return nil }
            defer { idx += 1 } // 延迟执行
            return data[idx]
        }
    }
    
    func makeIterator() -> Iter { Iter(data) }
    var underestimatedCount: Int { data.count }
}

// MARK: 6. 测试代码（可断点调试）
enum TestErr: Error {
    case invalidNumber
}
