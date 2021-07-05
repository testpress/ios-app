//
//  AttemptRepository.swift
//  ios-app
//
//  Created by Karthik on 12/05/20.
//  Copyright © 2020 Testpress. All rights reserved.
//

import Foundation

class AttemptRepository {
    func loadAttempt(attemptsUrl: String, completion: @escaping(ContentAttempt?, TPError?) -> Void) {
        TPApiClient.request(type: ContentAttempt.self, endpointProvider: TPEndpointProvider(.post, url: attemptsUrl), completion: completion)
    }
    
    func loadQuestions(url: String, examId: Int, attemptId: Int, completion: @escaping([AttemptItem]?, TPError?) -> Void) {
        let examQuestions = getExamquestionsFromDB(examId: examId)
        if (!examQuestions.isEmpty) {
            var attemptItems: [AttemptItem]
            if (getAttemtItems(attemptId: attemptId).isEmpty) {
                attemptItems = createAttemptItems(examQuestions: examQuestions, attemptId: attemptId)
            } else {
                attemptItems = getAttemtItems(attemptId: attemptId)
            }
            
            completion(attemptItems, nil)
            return
        }
        self.fetchQuestions(url: url, examId: examId, attemptId: attemptId, completion: completion)
    }
    
    func fetchQuestions(url: String, examId: Int, attemptId: Int, completion: @escaping([AttemptItem]?, TPError?) -> Void) {
        TPApiClient.request(type: ApiResponse<ExamQuestionsResponse>.self, endpointProvider: TPEndpointProvider(.get, url: url), completion:  { response, error in
            self.storeInDB(examQuestions: response?.results.parse() ?? [])
            if (!(response!.next.isEmpty)) {
                self.fetchQuestions(url: response!.next, examId: examId, attemptId: attemptId, completion: completion)
            } else {
                let examQuestions = self.getExamquestionsFromDB(examId: examId)
                let attemptItems = self.createAttemptItems(examQuestions: examQuestions, attemptId: attemptId)
                completion(attemptItems, error)
            }
        })
    }
    
    func getExamquestionsFromDB(examId: Int) -> [ExamQuestion] {
        return DBManager<ExamQuestion>().getItemsFromDB(filteredBy: "examId=\(examId)", byKeyPath: "order")
    }
    
    func storeInDB(examQuestions: [ExamQuestion]) {
        DBManager<ExamQuestion>().addData(objects: examQuestions)
    }
    
    func getAttemtItems(attemptId: Int) -> [AttemptItem] {
        return DBManager<AttemptItem>().getItemsFromDB(filteredBy: "attemptId=\(attemptId)", byKeyPath: "order")
    }
    
    func createAttemptItems(examQuestions: [ExamQuestion], attemptId: Int) -> [AttemptItem] {
        var attemptQuestions: [AttemptItem] = []
        let number = Int.random(in: 10000 ..< 999999)
        
        examQuestions.enumerated().forEach{ index, examQuestion in
            let attemptItem = AttemptItem()
            attemptItem.id = number + index
            attemptItem.index = index + 1
            attemptItem.order = examQuestion.order
            attemptItem.attemptId = attemptId
            attemptItem.question = examQuestion.question
            attemptItem.questionId = examQuestion.questionId
            attemptItem.examQuestionId = examQuestion.id
            attemptQuestions.append(attemptItem)
        }
        DBManager<AttemptItem>().addData(objects: attemptQuestions)
        return DBManager<AttemptItem>().getItemsFromDB(filteredBy: "attemptId=\(attemptId)", byKeyPath: "order")
    }
    
    func endExam(url: String, completion: @escaping(ContentAttempt?, TPError?) -> Void) {
        TPApiClient.request(
            type: ContentAttempt.self,
            endpointProvider: TPEndpointProvider(.put, url: url),
            completion: {
                contentAttempt, error in
                DBManager<Attempt>().addData(object: contentAttempt!.assessment)
                completion(contentAttempt, error)
        })
    }
}
