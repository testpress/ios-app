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
import Foundation

public class AttemptQuestion: DBModel {
    @objc dynamic public var questionHtml: String?;
    @objc dynamic public var subject: String = ""
    @objc dynamic public var subjectId: Int = -1
    @objc dynamic public var direction: String?;
    @objc dynamic public var directionId: Int = -1
    @objc dynamic public var explanationHtml: String?
    @objc dynamic public var type: String?;
    @objc dynamic public var commentsUrl: String! = ""
    public var answers = List<AttemptAnswer>()
    public var answerIds = List<Int>()
    public var translationIds = List<Int>()
    public var translations = List<AttemptQuestionTranslation>()
    @objc dynamic public var isCaseSensitive: Bool = false
    public var questionType: QuestionType {
        get {
            return QuestionType(rawValue: type ?? "Unknown") ?? .UNKNOWN
        }
    }
    public var isSingleMcq: Bool {
        get {questionType == .SINGLE_CORRECT_MCQ}
    }
    public var isMultipleMcq: Bool {
        get {questionType == .MULTIPLE_CORRECT_MCQ}
    }
    public var isShortAnswer: Bool {
        get {questionType == .SHORT_ANSWER}
    }
    public var isNumerical: Bool {
        get {questionType == .NUMERICAL}
    }
    public var isEssayType: Bool {
        get {questionType == .ESSAY}
    }
    public var isFileType: Bool {
        get {questionType == .FILE_TYPE}
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
        newAttemptItem.translations = translations
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
        translations <- (map["translations"], ListTransform<AttemptQuestionTranslation>())
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


extension AttemptQuestion {
    public func getLanguageBasedQuestion(_ language: Language?) -> String {
        if let selectedLanguage = language {
            for translation in self.translations {
                if translation.language == selectedLanguage.code {
                    return translation.questionHtml ?? self.questionHtml!
                }
            }
        }
        return self.questionHtml!
    }
    
    public func getLanguageBasedDirection(_ language: Language?) -> String {
        if let selectedLanguage = language {
            for translation in self.translations {
                if translation.language == selectedLanguage.code {
                    return translation.direction?.html ?? self.direction!
                }
            }
        }
        return self.direction!
    }
    
    public func getExplanationHtml(_ language: Language?) -> String? {
        if let selectedLanguage = language {
            for translation in self.translations {
                if translation.language == selectedLanguage.code {
                    return translation.explanationHtml
                }
            }
        }
        return self.explanationHtml
    }
}
