//
//  User.swift
//  ios-app
//
//  Copyright © 2017 Testpress. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import ObjectMapper

public class User {
    var username: String?
    var email: String?
    var password: String?
    var phone: String?
    var id: Int!
    var url: String?
    var displayName: String!
    var photo: String?
    var mediumImage: String!
    var largeImage: String?
    var averageSpeed: Int?
    var averageAccuracy: Int?
    var averagePercentage: Int?
    var testsCount: Int?
    var score: String?
    
    public required init?(map: Map) {
    }
}

extension User: TestpressModel {
    public func mapping(map: Map) {
        username <- map["username"]
        email <- map["email"]
        password <- map["password"]
        phone <- map["phone"]
        id <- map["id"]
        url <- map["url"]
        displayName <- map["display_name"]
        photo <- map["photo"]
        mediumImage <- map["medium_image"]
        largeImage <- map["large_image"]
        averageSpeed <- map["average_speed"]
        averageAccuracy <- map["average_accuracy"]
        averagePercentage <- map["average_percentage"]
        testsCount <- map["tests_count"]
        score <- map["score"]
    }
}
