//
//  Content.swift
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

public class Content {
    var url: String!
    var id: Int!
    var name: String!
    var description: String?
    var image: String!
    var modified: String!
    var chapterUrl: String!
    var attemptsUrl: String!
    var chapterSlug: String!
    var chapterId: Int!
    var attemptsCount: Int!
    var exam: Exam?
    var htmlContentTitle: String?
    var htmlContentUrl: String!
    var order: Int!
    var hasStarted: Bool!
    var isLocked: Bool!
    var video: Video?
    var attachment: Attachment?
    var active: Bool = true
    
    public required init?(map: Map) {
    }
}

extension Content: TestpressModel {
    public func mapping(map: Map) {
        url <- map["url"]
        id <- map["id"]
        name <- map["name"]
        description <- map["description"]
        image <- map["image"]
        modified <- map["modified"]
        chapterUrl <- map["chapter_url"]
        attemptsUrl <- map["attempts_url"]
        chapterSlug <- map["chapter_slug"]
        chapterId <- map["chapter_id"]
        attemptsCount <- map["attempts_count"]
        exam <- map["exam"]
        htmlContentTitle <- map["html_content_title"]
        htmlContentUrl <- map["html_content_url"]
        order <- map["order"]
        hasStarted <- map["has_started"]
        isLocked <- map["is_locked"]
        video <- map["video"]
        attachment <- map["attachment"]
        active <- map["active"]
    }
}
