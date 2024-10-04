//
//  UserStats.swift
//  ios-app
//
//  Created by Karthik on 29/04/21.
//  Copyright © 2021 Testpress. All rights reserved.
//

import ObjectMapper

public class UserStats {
    public var id: Int?
    public var dateFrom: String?
    public var attemptsCount: Int?
    public var attemptsCountDifference: Int?
    public var videoWatchedDuration: String?
    public var videoWatchedDurationDifference: String?
    public var category: String?
    
    
    public required init?(map: Map) {
        
    }
}

extension UserStats: TestpressModel {
    public func mapping(map: Map) {
        id <- map["id"]
        dateFrom <- map["date_from"]
        attemptsCount <- map["attempts_count"]
        attemptsCountDifference <- map["attempts_count_difference"]
        videoWatchedDuration <- map["video_watched_duration"]
        category <- map["category"]
    }
}

