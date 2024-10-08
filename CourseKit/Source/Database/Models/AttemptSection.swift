//
//  AttemptSection.swift
//  ios-app
//
//  Copyright © 2018 Testpress. All rights reserved.
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

public class AttemptSection: DBModel {
    
    @objc dynamic public var state: String = "Not Started"
    @objc dynamic public var questionsUrl: String = ""
    @objc dynamic public var startUrl: String = ""
    @objc dynamic public var endUrl: String = ""
    @objc dynamic public var remainingTime: String = ""
    @objc dynamic public var attemptId: Int = -1
    @objc dynamic public var name: String = ""
    @objc dynamic public var instructions: String = ""
    @objc dynamic public var duration: String = ""
    @objc dynamic public var order: Int = 0
    
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    public override func mapping(map: Map) {
        id <- map["id"]
        state <- map["state"]
        questionsUrl <- map["questions_url"]
        startUrl <- map["start_url"]
        endUrl <- map["end_url"]
        remainingTime <- map["remaining_time"]
        attemptId <- map["attempt_id"]
        name <- map["name"]
        instructions <- map["instructions"]
        duration <- map["duration"]
        order <- map["order"]
    }
}
