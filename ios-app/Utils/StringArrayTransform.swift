//
//  StringArrayTransform.swift
//  ios-app
//
//  Copyright © 2021 Testpress. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

public struct StringArrayTransform: TransformType {

    public init() { }

    public typealias Object = List<String>
    public typealias JSON = [String]

    public func transformFromJSON(_ value: Any?) -> List<String>? {
        guard let value = value else {
            return nil
        }
        let objects = value as! [String]
        let list = List<String>()
        list.append(objectsIn: objects)
        return list
    }

    public func transformToJSON(_ value: List<String>?) -> JSON? {
        return Array(value ?? List<String>())
    }

}
