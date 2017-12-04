//
//  Post.swift
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

public class Post {
    
    var url: String!
    var id: Int!
    var title: String!
    var summary: String!
    var shortWebUrl: String!
    var publishedDate: String!
    var modified: String!
    var commentsUrl: String!
    var commentsCount: Int!
    var isActive: Bool!
    var category: Category!
    var contentHtml: String!
    
    public required init?(map: Map) {
    }
}

extension Post: TestpressModel {
    public func mapping(map: Map) {
        url <- map["url"]
        id <- map["id"]
        title <- map["title"]
        summary <- map["summary"]
        shortWebUrl <- map["short_web_url"]
        publishedDate <- map["published_date"]
        modified <- map["modified"]
        commentsUrl <- map["comments_url"]
        commentsCount <- map["comments_count"]
        isActive <- map["is_active"]
        category <- map["category"]
        contentHtml <- map["content_html"]
    }
}
