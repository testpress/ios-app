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
import RealmSwift
import Foundation

public class Attempt: DBModel {
    
    public static let RUNNING = "Running";
    
    @objc public var url: String = "";
    @objc public var date: String?;
    @objc public var totalQuestions: Int = 0;
    @objc public var score: String?;
    @objc public var rank: Int = 0;
    @objc public var maxRank: Int = 0;
    @objc public var rankEnabled: Bool = false;
    @objc public var reviewUrl: String?;
    @objc public var questionsUrl: String?;
    @objc public var correctCount: Int = 0;
    @objc public var incorrectCount: Int = 0;
    @objc public var lastStartedTime: String?;
    @objc public var remainingTime: String?;
    @objc public var timeTaken: String?;
    @objc public var state: String?;
    @objc public var percentile: Double = 0
    @objc public var percentage: String = ""
    @objc public var speed: Int = 0
    @objc public var accuracy: Int = 0
    @objc public var exam: Int = -1
    @objc public var attemptType: Int = 0
    public var sections = List<AttemptSection>()
    

    override public static func primaryKey() -> String? {
        return "id"
    }
    
    public override func mapping(map: ObjectMapper.Map) {
        url <- map["url"]
        id <- map["id"]
        date <- map["date"]
        totalQuestions <- map["total_questions"]
        score <- map["score"]
        rank <- map["rank"]
        maxRank <- map["max_rank"]
        rankEnabled <- map["rank_enabled"]
        reviewUrl <- map["review_url"]
        questionsUrl <- map["questions_url"]
        correctCount <- map["correct_count"]
        incorrectCount <- map["incorrect_count"]
        lastStartedTime <- map["last_started_time"]
        remainingTime <- map["remaining_time"]
        timeTaken <- map["time_taken"]
        state <- map["state"]
        percentile <- map["percentile"]
        percentage <- map["percentage"]
        speed <- map["speed"]
        accuracy <- map["accuracy"]
        exam <- map["exam"]
        attemptType <- map["attempt_type"]
        sections <- (map["sections"], ListTransform<AttemptSection>())
    }

    public func hasScore() -> Bool {
        return self.score != nil && self.score != "NA"
    }
    
    public func getEndAttemptUrl() -> String {
        return url + "end/";
    }
}
