//
//  ExamQuestion.swift
//  ios-app
//
//  Created by Karthik on 12/05/20.
//  Copyright © 2020 Testpress. All rights reserved.
//

import ObjectMapper
import Foundation

public class ExamQuestion: DBModel {
    @objc dynamic public var marks = ""
    @objc dynamic public var negativeMarks = ""
    @objc dynamic public var order = -1
    @objc dynamic public var examId = 8989
    @objc dynamic public var attemptId = -1
    @objc dynamic public var question: AttemptQuestion? = nil
    @objc dynamic public var questionId: Int = -1
    
    override public func mapping(map: Map) {
        id <- map["id"]
        marks <- map["marks"]
        negativeMarks <- map["negative_marks"]
        order <- map["order"]
        examId <- map["exam_id"]
        attemptId <- map["attempt_id"]
        questionId <- map["question_id"]
    }
    
    override class public func primaryKey() -> String? {
        return "id"
    }
}
