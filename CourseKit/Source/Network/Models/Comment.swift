//
//  Comment.swift
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

public class Comment {
    
    public var url: String!
    public var id: Int!
    public var comment: String!
    public var created: String!
    public var upvotes: Int!
    public var downvotes: Int!
    public var voteId: Int?
    public var typeOfVote: Int!
    public var user: User!
    public var contentObject: ContentObject!
    
    public required init?(map: Map) {
    }
}

extension Comment: TestpressModel {
    public func mapping(map: Map) {
        url <- map["url"]
        id <- map["id"]
        comment <- map["comment"]
        created <- map["created"]
        upvotes <- map["upvotes"]
        downvotes <- map["downvotes"]
        voteId <- map["vote_id"]
        typeOfVote <- map["type_of_vote"]
        user <- map["user"]
        contentObject <- map["content_object"]
    }
}
