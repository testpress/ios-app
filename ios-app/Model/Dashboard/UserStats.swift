//
//  UserStats.swift
//  ios-app
//
//  Created by Karthik on 29/04/21.
//  Copyright © 2021 Testpress. All rights reserved.
//

import ObjectMapper
import CourseKit

class UserStats {
    var id: Int?
    var dateFrom: String?
    var attemptsCount: Int?
    var attemptsCountDifference: Int?
    var videoWatchedDuration: String?
    var videoWatchedDurationDifference: String?
    var category: String?
    
    
    public required init?(map: Map) {
        
    }
}

extension UserStats: TestpressModel {
    func mapping(map: Map) {
        id <- map["id"]
        dateFrom <- map["date_from"]
        attemptsCount <- map["attempts_count"]
        attemptsCountDifference <- map["attempts_count_difference"]
        videoWatchedDuration <- map["video_watched_duration"]
        category <- map["category"]
    }
}

