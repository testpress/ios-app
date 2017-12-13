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
    var url: String?;
    var question: AttemptQuestion!;
    var review: Bool! {
       didSet { review = review != nil && review }
    }
    var index: Int!
    var currentReview: Bool!
    var selectedAnswers: [Int] = [];
    var savedAnswers: [Int]!;
    var order: Int?
    var commentsCount: Int!
    var duration: Float!
    var bestDuration: Float!
    var averageDuration: Float!
    
    public required init?(map: Map) {
    }
    
    public func hasChanged() -> Bool {
        if savedAnswers == nil {
            savedAnswers = []
        }
        if currentReview == nil {
            currentReview = false
        }
        return savedAnswers != selectedAnswers || currentReview != review;
    }

}

extension AttemptItem: TestpressModel {
    public func mapping(map: Map) {
        url <- map["url"]
        question <- map["question"]
        review <- map["review"]
        index <- map["index"]
        currentReview <- map["current_review"]
        selectedAnswers <- map["selected_answers"]
        savedAnswers <- map["saved_answers"]
        order <- map["order"]
        commentsCount <- map["comments_count"]
        duration <- map["duration"]
        bestDuration <- map["best_duration"]
        averageDuration <- map["average_duration"]
    }
}
