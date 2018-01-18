//
//  Chapter.swift
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

public class Chapter {
    var url: String!
    var id: Int!
    var name: String!
    var description: String?
    var image: String!
    var modified: String!
    var courseUrl: String!
    var contentUrl: String!
    var childrenUrl: String!
    var slug: String!
    var contentsCount: Int!
    var childrenCount: Int!
    var courseId: Int!
    var parentId: Int?
    var requiredTrophyCount: Int!
    var order: Int!
    var leaf: Bool!
    var isLocked: Bool!
    var active: Bool = true
    
    public required init?(map: Map) {
    }
}

extension Chapter: TestpressModel {
    public func mapping(map: Map) {
        url <- map["url"]
        id <- map["id"]
        name <- map["name"]
        description <- map["description"]
        image <- map["image"]
        modified <- map["modified"]
        courseUrl <- map["course_url"]
        contentUrl <- map["content_url"]
        childrenUrl <- map["children_url"]
        slug <- map["slug"]
        contentsCount <- map["contents_count"]
        childrenCount <- map["children_count"]
        courseId <- map["course_id"]
        parentId <- map["parent_id"]
        requiredTrophyCount <- map["required_trophy_count"]
        order <- map["order"]
        leaf <- map["leaf"]
        isLocked <- map["is_locked"]
        active <- map["active"]
    }
}
