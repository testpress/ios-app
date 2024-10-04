//
//  LeaderboardItem.swift
//  ios-app
//
//  Created by Karthik on 29/04/21.
//  Copyright © 2021 Testpress. All rights reserved.
//

import ObjectMapper
import CourseKit

public class LeaderboardItem {
    var id: Int?
    var trophiesCount: String?
    var differene: Int?
    var category: Int?
    var user: User?
    
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
