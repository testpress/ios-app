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
import Realm
import RealmSwift

class Attempt: DBModel {
    
    public static let RUNNING = "Running";
    
    @objc var url: String = "";
    @objc  var date: String?;
    @objc var totalQuestions: Int = 0;
    @objc var score: String?;
    @objc var rank: Int = 0;
    @objc var maxRank: Int = 0;
    @objc var rankEnabled: Bool = false;
    @objc var reviewUrl: String?;
    @objc var questionsUrl: String?;
    @objc var correctCount: Int = 0;
    @objc var incorrectCount: Int = 0;
    @objc var lastStartedTime: String?;
    @objc var remainingTime: String?;
    @objc var timeTaken: String?;
    @objc var state: String?;
    @objc var percentile: Double = 0
    @objc var percentage: String = ""
    @objc var speed: Int = 0
    @objc var accuracy: Int = 0
    @objc var exam: Int = -1
    var sections = List<AttemptSection>()
    

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
        sections <- (map["sections"], ListTransform<AttemptSection>())
    }

    func hasScore() -> Bool {
        return self.score != nil && self.score != "NA"
    }
}
