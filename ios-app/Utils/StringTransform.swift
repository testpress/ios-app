//
//  IntTranform.swift
//  ios-app
//
//  Created by Karthik on 03/05/21.
//  Copyright © 2021 Testpress. All rights reserved.
//

import ObjectMapper

public struct StringTransform: TransformType {
    public typealias Object = String
    public typealias JSON = Any?

    public init() {}

    public func transformFromJSON(_ value: Any?) -> String? {

        var result: String?

        guard let json = value else {
            return String(result ?? "")
        }

        if json is Int {
            result = "\(json)"
        }

        return result
    }

    public func transformToJSON(_ value: String?) -> Any?? {

        guard let object = value else {
            return nil
        }

        return String(object)
    }
}
