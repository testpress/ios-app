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
import RealmSwift

class AttemptQuestion: DBModel {
    @objc dynamic var questionHtml: String?;
    @objc dynamic var subject: String = ""
    @objc dynamic var subjectId: Int = -1
    @objc dynamic var direction: String?;
    @objc dynamic var directionId: Int = -1
    @objc dynamic var explanationHtml: String?
    @objc dynamic var type: String?;
    @objc dynamic var commentsUrl: String! = ""
    var answers = List<AttemptAnswer>()
    var answerIds = List<Int>()
    var translationIds = List<Int>()
    @objc dynamic var isCaseSensitive: Bool = false
    var questionType: QuestionType {
        get {
            return QuestionType(rawValue: type ?? "Unknown") ?? .UNKNOWN
        }
    }
    var isSingleMcq: Bool {
        get {questionType == .SINGLE_CORRECT_MCQ}
    }
    var isMultipleMcq: Bool {
        get {questionType == .MULTIPLE_CORRECT_MCQ}
    }
    var isShortAnswer: Bool {
        get {questionType == .SHORT_ANSWER}
    }
    var isNumerical: Bool {
        get {questionType == .NUMERICAL}
    }
    var isEssayType: Bool {
        get {questionType == .ESSAY}
    }
    
    public  func clone() -> AttemptQuestion {
        let newAttemptItem = AttemptQuestion()
        newAttemptItem.id = id
        newAttemptItem.questionHtml = questionHtml
        newAttemptItem.subject = subject
        newAttemptItem.subjectId = subjectId
        newAttemptItem.direction = direction
        newAttemptItem.directionId = directionId
        newAttemptItem.explanationHtml = explanationHtml
        newAttemptItem.type = type
        newAttemptItem.commentsUrl = commentsUrl
        newAttemptItem.answers = answers
        newAttemptItem.answerIds = answerIds
        newAttemptItem.translationIds = translationIds
        newAttemptItem.isCaseSensitive = isCaseSensitive
        return newAttemptItem
    }
    
    
    override public static func primaryKey() -> String? {
        return "id"
    }

    public override func mapping(map: ObjectMapper.Map) {
        id <- map["id"]
        questionHtml <- map["question_html"]
        subject <- map["subject"]
        subjectId <- (map["subject_id"], transform)
        direction <- map["direction"]
        directionId <- (map["direction_id"], transform)
        explanationHtml <- map["explanation_html"]
        type <- map["type"]
        commentsUrl <- map["comments_url"]
        answers <- (map["answers"], ListTransform<AttemptAnswer>())
        answerIds <- map["answer_ids"]
        translationIds <- map["translation_ids"]
        isCaseSensitive <- map["is_case_sensitive"]
    }
    
    let transform = TransformOf<Int, Int>(fromJSON: { (value: Int?) -> Int? in
        return Int(value ?? -1)
    }, toJSON: { (value: Int?) -> Int? in
        return Int(value ?? -1)
    })

}

public enum QuestionType: String {
    case SINGLE_CORRECT_MCQ = "R"
    case MULTIPLE_CORRECT_MCQ = "C"
    case SHORT_ANSWER = "S"
    case NUMERICAL = "N"
    case ESSAY = "E"
    case FILE_TYPE = "F"
    case MATCH = "M"
    case NESTED = "T"
    case UNKNOWN = "Unknown"
}
