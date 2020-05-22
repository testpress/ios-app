//
//  ExamQuestionsResponse.swift
//  ios-app
//
//  Created by Karthik on 12/05/20.
//  Copyright © 2020 Testpress. All rights reserved.
//

import ObjectMapper

public class ExamQuestionsResponse {
    var directions: [Direction] = []
    var questions: [AttemptQuestion] = []
    var sections: [SectionInfo] = []
    var examQuestions: [ExamQuestion] = []
    
    var directionsDict = [Int: Direction]()
    var questionsDict = [Int: AttemptQuestion]()
    var sectionsDict = [Int: SectionInfo]()

    
    public required init?(map: Map) {
        mapping(map: map)
    }
    
    func parse() -> [ExamQuestion] {
        if (!examQuestions.isEmpty) {
            directions.forEach{ direction in
                directionsDict[direction.id] = direction
            }
            
            questions.forEach{ question in
                questionsDict[question.id] = question
            }
            
            sections.forEach{ section in
                sectionsDict[section.id] = section
            }
        }
        
        examQuestions.forEach{ examQuestion in
            if (examQuestion.questionId != -1) {
                examQuestion.question = questionsDict[examQuestion.questionId]
            }
        }
        
        return examQuestions
    }
}

extension ExamQuestionsResponse: TestpressModel {
    public func mapping(map: Map) {
        directions <- map["directions"]
        questions <- map["questions"]
        sections <- map["sections"]
        examQuestions <- map["exam_questions"]
    }
}
