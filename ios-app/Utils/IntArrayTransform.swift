//
//  IntArrayTransform.swift
//  ios-app
//
//  Created by Karthik on 26/05/20.
//  Copyright © 2020 Testpress. All rights reserved.
//
import ObjectMapper
import RealmSwift

// To convert IntAttay from JSON to List<Int> of realm
public struct IntArrayTransform: TransformType {

    public init() { }
    public typealias JSON = [Int]

    public func transformFromJSON(_ value: Any?) -> List<Int>? {
        guard let value = value else {
            return nil
        }
        let objects = value as! [Int]
        let list = List<Int>()
        list.append(objectsIn: objects)
        return list
    }

    public func transformToJSON(_ value: List<Int>?) -> JSON? {
        return Array(value ?? List<Int>())
    }

}
