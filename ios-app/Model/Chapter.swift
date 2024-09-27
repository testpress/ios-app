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
import Foundation

class Chapter: DBModel {
    @objc dynamic var url: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var details: String = ""
    @objc dynamic var image: String = ""
    @objc dynamic var modified: String = ""
    @objc dynamic var courseUrl: String = ""
    @objc dynamic var contentUrl: String = ""
    @objc dynamic var childrenUrl: String = ""
    @objc dynamic var slug: String = ""
    @objc dynamic var contentsCount: Int = 0
    @objc dynamic var childrenCount: Int = 0
    @objc dynamic var courseId: Int = 0
    @objc dynamic var parentId = -1
    @objc dynamic var requiredTrophyCount: Int = 0
    @objc dynamic var order: Int = 0
    @objc dynamic var leaf: Bool = false
    @objc dynamic var isLocked: Bool = false
    @objc dynamic var active: Bool = true
    

    public override func mapping(map: Map) {
        url <- map["url"]
        id <- map["id"]
        name <- map["name"]
        details <- map["description"]
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
    
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    public func getContentsUrl() -> String {
        return url + "contents/"
    }
}
