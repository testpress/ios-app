//
//  EssayTopic.swift
//  ios-app
//
//  Created by Karthik on 05/07/21.
//  Copyright © 2021 Testpress. All rights reserved.
//


import ObjectMapper
import RealmSwift

class EssayTopic: DBModel {
    @objc dynamic var id: Int = 0
    @objc dynamic var title: String = ""
    
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    public override func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
    }
}
