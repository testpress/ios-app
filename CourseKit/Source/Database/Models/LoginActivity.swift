//
//  LoginActivity.swift
//  ios-app
//
//  Created by Karthik on 16/04/19.
//  Copyright © 2019 Testpress. All rights reserved.
//

import ObjectMapper
import Foundation

public class LoginActivity: DBModel {
    @objc public dynamic var userAgent: String = ""
    @objc public dynamic var ipAddress: String = ""
    @objc public dynamic var lastUsed: String = ""
    @objc public dynamic var location: String = ""
    @objc public dynamic var currentDevice: Bool = false

    
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
