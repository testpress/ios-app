//
//  ActivityFeed.swift
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
import CourseKit

public class ActivityFeed {
    
    var id: Int!
    var actorContentType: Int!
    var actorObjectId: String!
    var targetContentType: Int!
    var targetObjectId: String!
    var actionObjectContentType: Int!
    var actionObjectObjectId: String!
    var timestamp: String!
    var verb: String!
    var actor: User!
    var target: Any!
    var actionObject: Any!
    var actionObjectType: String!
    
    public required init?(map: Map) {
    }
}

extension ActivityFeed: TestpressModel {
    
    public func mapping(map: Map) {
        
        id <- map["id"]
        actorContentType <- map["actor_content_type"]
        actorObjectId <- map["actor_object_id"]
        targetContentType <- map["target_content_type"]
        targetObjectId <- map["target_object_id"]
        actionObjectContentType <- map["action_object_content_type"]
        actionObjectObjectId <- map["action_object_object_id"]
        timestamp <- map["timestamp"]
        verb <- map["verb"]
    }
}
