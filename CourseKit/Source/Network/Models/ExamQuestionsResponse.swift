//
//  ExamQuestionsResponse.swift
//  ios-app
//
//  Created by Karthik on 12/05/20.
//  Copyright © 2020 Testpress. All rights reserved.
//

import ObjectMapper

public class ExamQuestionsResponse {
    public var directions: [Direction] = []
    public var questions: [AttemptQuestion] = []
    public var sections: [SectionInfo] = []
    public var examQuestions: [ExamQuestion] = []
    
    public var directionsDict = [Int: Direction]()
    public var questionsDict = [Int: AttemptQuestion]()
    public var sectionsDict = [Int: SectionInfo]()

    
    public required init?(map: Map) {
        mapping(map: map)
    }
    
    public func parse() -> [ExamQuestion] {
        if (!examQuestions.isEmpty) {
            directions.forEach{ direction in
                directionsDict.updateValue(direction, forKey: direction.id)
            }
            
            questions.forEach{ question in
                questionsDict.updateValue(question, forKey: question.id)
            }
            
            sections.forEach{ section in
                sectionsDict.updateValue(section, forKey: section.id)
            }
        }
        
        examQuestions.forEach{ examQuestion in
            if (examQuestion.questionId != -1) {
                examQuestion.question = questionsDict[examQuestion.questionId]
                if (examQuestion.question?.directionId != -1) {
                    examQuestion.question?.direction = directionsDict[examQuestion.question!.directionId]?.html

                }
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
