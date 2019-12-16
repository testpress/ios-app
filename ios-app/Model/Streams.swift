//
//  Streams.swift
//  ios-app
//
//  Created by Karthik raja on 12/11/19.
//  Copyright © 2019 Testpress. All rights reserved.
//

import ObjectMapper

public class Stream {
    var url: String!
    var id: Int!
    var format: String!
    
    public required init?(map: Map) {
    }
}

extension Stream: TestpressModel {
    public func mapping(map: Map) {
        url <- map["url"]
        id <- map["id"]
        format <- map["format"]
    }
}
