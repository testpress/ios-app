//
//  Error.swift
//  ios-app
//
//  Created by Karthik on 15/04/19.
//  Copyright © 2019 Testpress. All rights reserved.
//


import ObjectMapper

public class ApiError {
    var error_code: String?
    var detail: String?
    
    public required init?(map: Map) {
    }
}

extension ApiError: TestpressModel {
    public func mapping(map: Map) {
        error_code <- map["error_code"]
        detail <- map["detail"]
    }
}
