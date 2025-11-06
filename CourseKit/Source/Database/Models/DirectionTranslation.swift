//
//  DirectionTranslation.swift
//  ios-app
//
//  Created by Prithuvi on 19/12/23.
//  Copyright © 2023 Testpress. All rights reserved.
//

import ObjectMapper
import Foundation

public class DirectionTranslation: DBModel {
    
    @objc dynamic public var html: String = ""

    public override func mapping(map: Map) {
        id <- map["id"]
        html <- map["html"]
    }
    
    public override class func primaryKey() -> String? {
        return "id"
    }
}
