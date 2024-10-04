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
import Foundation


public class AttemptItem: DBModel {
    public static let ANSWERED_CORRECT = "Correct"
    public static let ANSWERED_INCORRECT = "Incorrect"
    public static let UNANSWERED = "Unanswered"
    
    @objc public dynamic var url: String = "";
    @objc public dynamic var question: AttemptQuestion!;
    @objc public dynamic var questionId: Int = -1
    @objc public dynamic var review: Bool = false
    @objc public dynamic var isAttempted: Bool = false
    @objc public dynamic var index: Int = -1
    @objc public dynamic var currentReview: Bool = false
    public var selectedAnswers = List<Int>()
    public var savedAnswers = List<Int>()
    @objc public dynamic var order: Int = 0
    @objc public dynamic var commentsCount: Int = 0
    @objc public dynamic var duration: Float = 0.0
    @objc public dynamic var bestDuration: Float = 0.0
    @objc public dynamic var averageDuration: Float = 0.0
    public var bookmarkId: Int? = nil
    @objc public dynamic var attemptSection: AttemptSection?
    @objc public dynamic var shortText: String?
    @objc public dynamic var currentShortText: String!
    @objc public dynamic var marks: String?
    @objc public dynamic var result: String!
    @objc public dynamic var attemptId: Int = -1
    @objc public dynamic var examQuestionId: Int = -1
    public var gapFillResponses = List<GapFillResponse>()
    @objc public dynamic var essayText: String?
    @objc public dynamic var localEssayText: String!
    public var files = List<UserFileResponse>()
    public var localFiles = List<UserFileResponse>()
    
    public required convenience init?(map: ObjectMapper.Map) {
        self.init()
    }
    
    override public static func primaryKey() -> String? {
        return "id"
    }

    public override func mapping(map: ObjectMapper.Map) {
        let userFileResponseListTransform = getUserFileResponseListTransform()
        
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
        files <- (map["files"], userFileResponseListTransform)
        localFiles <- (map["files"], userFileResponseListTransform)
    }
    

    // Handles the transformation of user-uploaded file responses from the API, which can be either a list of strings (file paths) or a list of JSON objects (UserFileResponse).
    public func getUserFileResponseListTransform() -> TransformOf<List<UserFileResponse>, Any> {
        return TransformOf<List<UserFileResponse>, Any>(fromJSON: { (value: Any?) -> List<UserFileResponse>? in
            let list = List<UserFileResponse>()
            if let stringArray = value as? [String] {
                for path in stringArray {
                    let response = UserFileResponse.create(uploadedPath: path)
                    list.append(response)
                }
            } else if let jsonArray = value as? [Any] {
                if let objects = Mapper<UserFileResponse>().mapArray(JSONObject: jsonArray) {
                    list.append(objectsIn: objects)
                }
            }
            return list
        }, toJSON: { (value: List<UserFileResponse>?) -> Any? in
            return value?.compactMap { $0.toJSON() }
        })
    }
    
    public func setGapFillResponses(_ gapFillOrderAnswerMap: [Int: AnyObject] ) {
        DBManager<AttemptItem>().write {
            let gapFillResponseList = List<GapFillResponse>()
            gapFillOrderAnswerMap.forEach {
                let response = GapFillResponse.create(order: $0, answer: $1 as! String)
                gapFillResponseList.append(response)
            }
            
            self.gapFillResponses.removeAll()
            self.gapFillResponses.append(objectsIn: gapFillResponseList)
        }
    }
    
    private func compareUserFileResponsePaths(_ list1: List<UserFileResponse>, _ list2: List<UserFileResponse>) -> Bool {
        let paths1 = Set(list1.map { $0.path })
        let paths2 = Set(list2.map { $0.path })
        
        return paths1 == paths2
    }
    
    public func hasChanged() -> Bool {
        let reviewStatusChanged = currentReview != review
        let answersChanged = savedAnswers != selectedAnswers
        let shortTextChanged = (shortText != nil && shortText != currentShortText) ||
                               (shortText == nil && currentShortText != nil && !currentShortText.isEmpty)
        let filesChanged = !compareUserFileResponsePaths(files, localFiles)
        let essayTextChanged = localEssayText != essayText
        
        return answersChanged || reviewStatusChanged || shortTextChanged || filesChanged || essayTextChanged || !gapFillResponses.isEmpty
    }
}
