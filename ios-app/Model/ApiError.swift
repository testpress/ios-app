//
//  Error.swift
//  ios-app
//
//  Created by Karthik on 15/04/19.
//  Copyright © 2019 Testpress. All rights reserved.
//


import ObjectMapper
import CourseKit

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


public class TestpressAPIError: TestpressModel {
    var detail: ErrorDetail?
    
    public required init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        detail <- map["detail"]
    }
}


class ErrorDetail: TestpressModel {
    var error_code: String?
    var message: String?
    
    public required init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        error_code <- map["error_code"]
        message <- map["message"]
    }
}
