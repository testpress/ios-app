//
//  ContentAttempt.swift
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

public class ContentAttempt {
    
    public var id: Int!
    public var type: String!
    public var trophies: Any!
    public var objectUrl: String!
    public var assessment: Attempt!
    public var video: VideoAttempt!
    public var content: HtmlContent!
    public var attachment: Attachment!
    public var chapterContentId: Int!
    public var objectID: Int!
    
    public required init?(map: Map) {
    }
    
    public func getEndAttemptUrl() -> String {
        return TestpressCourse.shared.baseURL + TPEndpoint.contentAttempts.urlPath + "\(id!)/" +
            TPEndpoint.endExam.urlPath;
    }
}

extension ContentAttempt: TestpressModel {
    public func mapping(map: Map) {
        type <- map["type"]
        id <- map["id"]
        trophies <- map["trophies"]
        objectUrl <- map["objectUrl"]
        video <- map["video"]
        assessment <- map["assessment"]
        content <- map["content"]
        attachment <- map["attachment"]
        chapterContentId <- map["chapter_content"]
        objectID <- map["object_id"]
    }
}
