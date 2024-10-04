//
//  ActivityFeedResponse.swift
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

public class ActivityFeedResponse {
    
    public var activities: [ActivityFeed] = []
    public var users: [User] = []
    public var contentTypes: [ContentType] = []
    public var chapters: [Chapter] = []
    public var chapterContents: [Content] = []
    public var chapterContentAttempts: [ContentAttempt] = []
    public var htmlContents: [HtmlContent] = []
    public var videoContents: [Video] = []
    public var exams: [Exam] = []
    public var attachmentContents: [Attachment] = []
    public var posts: [Post] = []
    public var postCategories: [Category] = []
    
    public required init?(map: Map) {
        mapping(map: map)
    }
}

extension ActivityFeedResponse: TestpressModel {
    
    public func mapping(map: Map) {
        
        activities <- map["activities"]
        users <- map["users"]
        contentTypes <- map["content_types"]
        chapters <- map["chapters"]
        chapterContents <- map["chaptercontents"]
        chapterContentAttempts <- map["chaptercontentattempts"]
        htmlContents <- map["html_contents"]
        videoContents <- map["video_contents"]
        exams <- map["exams"]
        attachmentContents <- map["attachment_contents"]
        posts <- map["posts"]
        postCategories <- map["postcategories"]
    }
}
