//
//  Attempt.swift
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

public class Attempt {
    var url: String?;
    var id: Int?;
    var date: String?;
    var totalQuestions: Int?;
    var score: String?;
    var rank: String?;
    var reviewUrl: String?;
    var questionsUrl: String?;
    var correctCount: Int?;
    var incorrectCount: Int?;
    var lastStartedTime: String?;
    var remainingTime: String?;
    var timeTaken: String?;
    var state: String?;
    var percentile: String?;
    
    public required init?(map: Map) {
    }
}

extension Attempt: TestpressModel {
    public func mapping(map: Map) {
        url <- map["url"]
        id <- map["id"]
        date <- map["title"]
        totalQuestions <- map["total_questions"]
        score <- map["score"]
        rank <- map["rank"]
        reviewUrl <- map["review_url"]
        questionsUrl <- map["questions_url"]
        correctCount <- map["correct_count"]
        incorrectCount <- map["incorrect_count"]
        lastStartedTime <- map["last_started_time"]
        remainingTime <- map["remaining_time"]
        timeTaken <- map["time_taken"]
        state <- map["state"]
        percentile <- map["percentile"]
    }
}
