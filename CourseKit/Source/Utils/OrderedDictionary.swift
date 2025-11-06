//
//  OrderedDictionary.swift
//  ios-app
//
//  Copyright © 2017 Testpress. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

public struct OrderedDictionary<K: Hashable, V> {
    public var keys: Array<K> = []
    public var dict: Dictionary<K, V> = [:]
    
    public var count: Int {
        assert(keys.count == dict.count, "Keys and values array out of sync")
        return self.keys.count;
    }
    
    // Explicitly define an empty initializer to prevent the default memberwise initializer from
    // being generated
    public init() {}
    
    public subscript(key: K) -> V? {
        get {
            return self.dict[key]
        }
        set(newValue) {
            if newValue == nil {
                self.dict.removeValue(forKey: key)
                self.keys = self.keys.filter {$0 != key}
            } else {
                let oldValue = self.dict.updateValue(newValue!, forKey: key)
                if oldValue == nil {
                    self.keys.append(key)
                }
            }
        }
    }
    
    public var values: [V] {
        var values: Array<V> = []
        for key in keys {
            if let value = dict[key] {
                values.append(value)
            }
        }
        return values
    }
    
    public mutating func removeAll() {
        keys.removeAll()
        dict.removeAll()
    }
    
    public var description: String {
        var result = "{\n"
        for i in 0..<count {
            result += "[\(i)]: \(keys[i]) => \(String(describing: self[keys[i]]))\n"
        }
        result += "}"
        return result
    }
}
