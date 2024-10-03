//
//  LoginActivity.swift
//  ios-app
//
//  Created by Karthik on 16/04/19.
//  Copyright © 2019 Testpress. All rights reserved.
//

import ObjectMapper
import Foundation

class LoginActivity: DBModel {
    
    @objc dynamic var userAgent: String = ""
    @objc dynamic var ipAddress: String = ""
    @objc dynamic var lastUsed: String = ""
    @objc dynamic var location: String = ""
    @objc dynamic var currentDevice: Bool = false

    
    public override func mapping(map: ObjectMapper.Map) {
        id <- map["id"]
        userAgent <- map["user_agent"]
        ipAddress <- map["ip_address"]
        lastUsed <- map["last_used"]
        location <- map["location"]
        currentDevice <- map["current_device"]
    }
    
    override public static func primaryKey() -> String? {
        return "id"
    }
}
