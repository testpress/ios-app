//
//  Banner.swift
//  ios-app
//
//  Created by Karthik on 29/04/21.
//  Copyright © 2021 Testpress. All rights reserved.
//

import ObjectMapper

public class Banner {
    var id: Int?
    var url: String?
    var image: String?
    
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
