//
//  Banner.swift
//  ios-app
//
//  Created by Karthik on 29/04/21.
//  Copyright © 2021 Testpress. All rights reserved.
//

import ObjectMapper
import CourseKit

public class Banner {
    public var id: Int?
    public var url: String?
    public var image: String?
    
    public required init?(map: Map) {
        
    }
}

extension Banner: TestpressModel {
    public func mapping(map: Map) {
        id <- map["id"]
        url <- map["url"]
        image <- map["image"]
    }
}
