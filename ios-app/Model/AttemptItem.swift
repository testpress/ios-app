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

public class AttemptItem {
    
    public static let ANSWERED_CORRECT = "Correct"
    public static let ANSWERED_INCORRECT = "Incorrect"
    public static let UNANSWERED = "Unanswered"
    
    var id: Int!
    var url: String?;
    var question: AttemptQuestion!;
    var questionId: Int!
    var review: Bool! {
       didSet { review = review != nil && review }
    }
    var index: Int!
    var currentReview: Bool!
    var selectedAnswers: [Int] = []
    var savedAnswers: [Int] = []
    var order: Int?
    var commentsCount: Int!
    var duration: Float!
    var bestDuration: Float!
    var averageDuration: Float!
    var bookmarkId: Int!
    var attemptSection: AttemptSection!
    var shortText: String?
    var currentShortText: String!
    var marks: String?
    var result: String!
    
    public required init?(map: Map) {
    }
    
    public func hasChanged() -> Bool {
        if currentReview == nil {
            currentReview = false
        }
        return savedAnswers != selectedAnswers || currentReview != review ||
            (shortText != nil && shortText != currentShortText) ||
            (shortText == nil && currentShortText != nil && !currentShortText.isEmpty)
    }

}

extension AttemptItem: TestpressModel {
    public func mapping(map: Map) {
        id <- map["id"]
        url <- map["url"]
        question <- map["question"]
        questionId <- map["question_id"]
        review <- map["review"]
        index <- map["index"]
        currentReview <- map["current_review"]
        selectedAnswers <- map["selected_answers"]
        selectedAnswers <- map["selected_answer_ids"]
        savedAnswers <- map["saved_answers"]
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
    }
}
