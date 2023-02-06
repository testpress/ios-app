//
//  AttemptItem.swift
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


class AttemptItem: DBModel {
    
    public static let ANSWERED_CORRECT = "Correct"
    public static let ANSWERED_INCORRECT = "Incorrect"
    public static let UNANSWERED = "Unanswered"
    
    @objc dynamic var id: Int = -1
    @objc dynamic var url: String = "";
    @objc dynamic var question: AttemptQuestion!;
    @objc dynamic var questionId: Int = -1
    @objc dynamic var review: Bool = false
    @objc dynamic var isAttempted: Bool = false
    @objc dynamic var index: Int = -1
    @objc dynamic var currentReview: Bool = false
    var selectedAnswers = List<Int>()
    var savedAnswers = List<Int>()
    @objc dynamic var order: Int = 0
    @objc dynamic var commentsCount: Int = 0
    @objc dynamic var duration: Float = 0.0
    @objc dynamic var bestDuration: Float = 0.0
    @objc dynamic var averageDuration: Float = 0.0
    var bookmarkId: Int? = nil
    @objc dynamic var attemptSection: AttemptSection?
    @objc dynamic var shortText: String?
    @objc dynamic var currentShortText: String!
    @objc dynamic var marks: String?
    @objc dynamic var result: String!
    @objc dynamic var attemptId: Int = -1
    @objc dynamic var examQuestionId: Int = -1
    var gapFillResponses = List<GapFillResponse>()
    @objc dynamic var essayText: String?
    @objc dynamic var localEssayText: String!
    
    public required convenience init?(map: Map) {
        self.init()
    }
    
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    public func hasChanged() -> Bool {
        if currentReview == nil {
            currentReview = false
        }
        return savedAnswers != selectedAnswers || currentReview != review ||
            (shortText != nil && shortText != currentShortText) ||
            (shortText == nil && currentShortText != nil && !currentShortText.isEmpty)
    }
    
    public func getSaveUrl() -> String {
        return String(format: "%@/api/v2.4/attempts/%d/questions/%d/", Constants.BASE_URL , self.attemptId, self.examQuestionId)
    }
    
    public func setGapFillResponses(_ gapFillOrderAnswerMap: [Int: AnyObject] ) {
        try! Realm().write {
            let gapFillResponseList = List<GapFillResponse>()
            gapFillOrderAnswerMap.forEach {
                let response = GapFillResponse.create(order: $0, answer: $1 as! String)
                gapFillResponseList.append(response)
            }
            
            self.gapFillResponses.removeAll()
            self.gapFillResponses.append(objectsIn: gapFillResponseList)
        }
    }

    public override func mapping(map: Map) {
        id <- map["id"]
        url <- map["url"]
        question <- map["question"]
        questionId <- map["question_id"]
        review <- map["review"]
        index <- map["index"]
        currentReview <- map["current_review"]
        selectedAnswers <- (map["selected_answers"], IntArrayTransform())
        savedAnswers <- (map["saved_answers"], IntArrayTransform())
        order <- map["order"]
        commentsCount <- map["comments_count"]
        duration <- map["duration"]
        bestDuration <- map["best_duration"]
        averageDuration <- map["average_duration"]
        bookmarkId <- map["bookmark_id"]
        attemptSection <- map["attempt_section"]
        shortText <- map["short_text"]
        marks <- map["marks"]
        result <- map["result"]
        attemptId <- map["attempt_id"]
        gapFillResponses <- (map["gap_fill_responses"], ListTransform<GapFillResponse>())
        essayText <- map["essay_text"]
    }
}
