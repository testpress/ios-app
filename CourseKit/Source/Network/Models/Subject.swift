//
//  Subject.swift
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

public class Subject {
    
    public var id: Int!
    public var name: String!
    public var parent: Int!
    public var total: Int!
    public var correct: Int!
    public var incorrect: Int!
    public var unanswered: Int!
    public var percentage: Double!
    public var incorrectPercentage: Double!
    public var unansweredPercentage: Double!
    public var leaf: Bool!
    
    public required init?(map: Map) {
    }
}

extension Subject: TestpressModel {
    public func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        parent <- map["parent"]
        total <- map["total"]
        correct <- map["correct"]
        incorrect <- map["incorrect"]
        unanswered <- map["unanswered"]
        percentage <- map["percentage"]
        leaf <- map["leaf"]
    }
}
