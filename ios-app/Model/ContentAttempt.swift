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
    
    var id: Int!
    var type: String!
    var trophies: Any!
    var objectUrl: String!
    var assessment: Attempt!
    var video: Video!
    var content: HtmlContent!
    var attachment: Attachment!
    var chapterContentId: Int!
    
    public required init?(map: Map) {
    }
    
    public func getEndAttemptUrl() -> String {
        return Constants.BASE_URL + TPEndpoint.contentAttempts.urlPath + "\(id!)/" +
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
    }
}
