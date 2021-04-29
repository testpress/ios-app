//
//  UserDefaults.swift
//  ios-app
//
//  Created by Karthik on 26/04/21.
//  Copyright © 2021 Testpress. All rights reserved.
//

import ObjectMapper

extension UserDefaults: ObjectSavable {
    func saveObject<Object>(_ object: Object, forKey: String) throws where Object: Mappable {
        let data = object.toJSONString()
        set(data, forKey: forKey)
    }

    func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Mappable {
        guard let data = string(forKey: forKey) else { throw ObjectSavableError.noValue }
        let object = type.init(JSONString: data)
        return object!
    }
}

protocol ObjectSavable {
    func saveObject<Object>(_ object: Object, forKey: String) throws where Object: Mappable
    func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Mappable
}

enum ObjectSavableError: String, LocalizedError {
    case unableToEncode = "Unable to encode object into data"
    case noValue = "No data object found for the given key"
    case unableToDecode = "Unable to decode object into given type"
    
    var errorDescription: String? {
        rawValue
    }
}
