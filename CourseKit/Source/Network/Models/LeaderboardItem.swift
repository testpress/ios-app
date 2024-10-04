//
//  LeaderboardItem.swift
//  ios-app
//
//  Created by Karthik on 29/04/21.
//  Copyright © 2021 Testpress. All rights reserved.
//

import ObjectMapper

public class LeaderboardItem {
    public var id: Int?
    public var trophiesCount: String?
    public var differene: Int?
    public var category: Int?
    public var user: User?
    
    public required init?(map: Map) {
    }
}


extension LeaderboardItem: TestpressModel {
    public func mapping(map: Map) {
        id <- map["id"]
        trophiesCount <- map["trophies_count"]
        differene <- map["difference"]
        category <- map["category"]
        user <- map["user"]
    }
    
}
