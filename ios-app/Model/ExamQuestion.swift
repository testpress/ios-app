//
//  ExamQuestion.swift
//  ios-app
//
//  Created by Karthik on 12/05/20.
//  Copyright © 2020 Testpress. All rights reserved.
//

import ObjectMapper
import Foundation

class ExamQuestion: DBModel {
    @objc dynamic var marks = ""
    @objc dynamic var negativeMarks = ""
    @objc dynamic var order = -1
    @objc dynamic var examId = 8989
    @objc dynamic var attemptId = -1
    @objc dynamic var question: AttemptQuestion? = nil
    @objc dynamic var questionId: Int = -1
    
    override func mapping(map: Map) {
        id <- map["id"]
        marks <- map["marks"]
        negativeMarks <- map["negative_marks"]
        order <- map["order"]
        examId <- map["exam_id"]
        attemptId <- map["attempt_id"]
        questionId <- map["question_id"]
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
