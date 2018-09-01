//
//  AttemptQuestion.swift
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

public class AttemptQuestion {
    var id: Int?
    var questionHtml: String?;
    var subject: String!
    var subjectId: Int!
    var direction: String?;
    var directionId: Int!
    var explanationHtml: String?
    var type: String?;
    var commentsUrl: String!
    var answers: [AttemptAnswer] = [];
    var answerIds: [Int] = []
    var translationIds: [Int] = []
    var isCaseSensitive: Bool!
    
    public required init?(map: Map) {
    }
}

extension AttemptQuestion: TestpressModel {
    public func mapping(map: Map) {
        id <- map["id"]
        questionHtml <- map["question_html"]
        subject <- map["subject"]
        subjectId <- map["subject_id"]
        direction <- map["direction"]
        directionId <- map["direction_id"]
        explanationHtml <- map["explanation_html"]
        type <- map["type"]
        commentsUrl <- map["comments_url"]
        answers <- map["answers"]
        answerIds <- map["answer_ids"]
        translationIds <- map["translation_ids"]
        isCaseSensitive <- map["is_case_sensitive"]
    }
}
