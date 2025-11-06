//
//  DashboardSection.swift
//  ios-app
//
//  Created by Karthik on 29/04/21.
//  Copyright © 2021 Testpress. All rights reserved.
//

import ObjectMapper

public class DashboardSection {
    public var slug: String?
    public var displayName: String?
    public var url: String?
    public var contentType: String?
    public var order: Int?
    public var displayType: String?
    public var items: [Int]?
    
    public required init?(map: Map) {
        mapping(map: map)
    }
}


extension DashboardSection: TestpressModel {
    public func mapping(map: Map) {
        slug <- map["slug"]
        displayName <- map["display_name"]
        url <- map["url"]
        contentType <- map["content_type"]
        order <- map["order"]
        displayType <- map["display_type"]
        items <- map["items"]
    }
}
