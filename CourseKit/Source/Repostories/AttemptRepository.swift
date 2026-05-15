//
//  AttemptRepository.swift
//  ios-app
//
//  Created by Karthik on 12/05/20.
//  Copyright © 2020 Testpress. All rights reserved.
//

import Foundation

public class AttemptRepository {
    public init() {}
    
    public func loadContentAttempt(attemptsUrl: String, completion: @escaping(ContentAttempt?, TPError?) -> Void) {
        TPApiClient.request(type: ContentAttempt.self, endpointProvider: TPEndpointProvider(.post, url: attemptsUrl), completion: completion)
    }

    public func loadQuestions(url: String, examId: Int, attemptId: Int, completion: @escaping([AttemptItem]?, TPError?) -> Void) {
        let examQuestions = getExamquestionsFromDB(examId: examId, attemptId: attemptId)
        if (!examQuestions.isEmpty) {
            var attemptItems: [AttemptItem]
            if (getAttemtItems(attemptId: attemptId).isEmpty) {
                attemptItems = createAttemptItems(examQuestions: examQuestions, attemptId: attemptId)
            } else {
                attemptItems = getAttemtItems(attemptId: attemptId)
            }
            completion(attemptItems, nil)
            fetchQuestions(url:url, attemptId: attemptId, examId: examId, completion: nil)
            return
        }
        
        fetchQuestions(url: url, attemptId: attemptId, examId: examId, completion: completion)
    }
    
    public func fetchQuestions(url: String, attemptId: Int, examId: Int, completion: (([AttemptItem]?, TPError?) -> Void)?) {
        
        TPApiClient.request(type: ApiResponse<ExamQuestionsResponse>.self, endpointProvider: TPEndpointProvider(.get, url: url), completion:  { response, error in
            self.storeInDB(examQuestions: response?.results.parse() ?? [],examId: examId, attemptId: attemptId)
            if (response?.next != nil && response?.next.isEmpty == false) {
                self.fetchQuestions(url: response!.next, attemptId: attemptId, examId: examId, completion: completion)
            } else if (completion != nil) {
                let examQuestions = self.getExamquestionsFromDB(examId: examId, attemptId: attemptId)
                let attemptItems = self.createAttemptItems(examQuestions: examQuestions, attemptId: attemptId)
                completion?(attemptItems, error)
            }
            
        })
    }
    public func getExamquestionsFromDB(examId: Int, attemptId: Int) -> [ExamQuestion] {
        if examId == -1 {
            return DBManager<ExamQuestion>().getItemsFromDB(filteredBy: "attemptId=\(attemptId)", byKeyPath: "order")
        } else {
            return DBManager<ExamQuestion>().getItemsFromDB(filteredBy: "examId=\(examId)", byKeyPath: "order")
        }
    }
    
    public func storeInDB(examQuestions: [ExamQuestion], examId: Int, attemptId: Int) {
        for question in examQuestions {
                question.examId = examId
                question.attemptId = attemptId
            }
        DBManager<ExamQuestion>().addData(objects: examQuestions)
    }
    
    public func getAttemtItems(attemptId: Int) -> [AttemptItem] {
        return DBManager<AttemptItem>().getItemsFromDB(filteredBy: "attemptId=\(attemptId)", byKeyPath: "order")
    }
    
    public func createAttemptItems(examQuestions: [ExamQuestion], attemptId: Int) -> [AttemptItem] {
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
    
    public func endExam(url: String, completion: @escaping(ContentAttempt?, TPError?) -> Void) {
        TPApiClient.request(
            type: ContentAttempt.self,
            endpointProvider: TPEndpointProvider(.put, url: url),
            completion: {
                contentAttempt, error in
                if let assessment = contentAttempt?.assessment {
                    DBManager<Attempt>().addData(object: assessment)
                }
                completion(contentAttempt, error)
        })
    }
    
    public func endAttempt(url: String, completion: @escaping(Attempt?, TPError?) -> Void) {
        TPApiClient.request(
            type: Attempt.self,
            endpointProvider: TPEndpointProvider(.put, url: url),
            completion: {
                attempt, error in
                if let attempt = attempt {
                    DBManager<Attempt>().addData(object: attempt)
                }
                completion(attempt, error)
        })
    }

    private func fetchAttempts<T: TestpressModel>(attemptsUrl: String,type: T.Type,queryParams: [String: String] = [:],completion: @escaping ([T]?, TPError?) -> Void) {
        TPApiClient.getListItems(endpointProvider: TPEndpointProvider(.loadAttempts,url: attemptsUrl,queryParams: queryParams),completion: { (response: TPApiResponse<T>?, error: TPError?) in
                if let error = error {
                    completion(nil, error)
                    return
                }
                completion(response?.results, nil)
            },
            type: T.self
        )
    }

    public func fetchRunningAttempt(exam: Exam, content: Content?, completion: @escaping (ContentAttempt?, Attempt?, TPError?) -> Void) {
        let url = content?.getAttemptsUrl() ?? exam.attemptsUrl
        guard !url.isEmpty else {
            completion(nil, nil, nil)
            return
        }

        if content != nil {
            fetchAttempts(attemptsUrl: url, type: ContentAttempt.self, queryParams: [Constants.STATE: "paused"]) { attempts, error in
                let contentAttempt = attempts?.first
                completion(contentAttempt, contentAttempt?.assessment, error)
            }
        } else {
            fetchAttempts(attemptsUrl: url, type: Attempt.self, queryParams: [Constants.STATE: "paused"]) { attempts, error in
                completion(nil, attempts?.first, error)
            }
        }
    }

    public func endRunningAttempt(exam: Exam, content: Content?, currentAttempt: Attempt?, currentContentAttempt: ContentAttempt?, completion: @escaping (ContentAttempt?, Attempt?, TPError?) -> Void) {
        if let ca = currentContentAttempt {
            endExam(url: ca.getEndAttemptUrl()) { r, e in completion(r, r?.assessment, e) }
        } else if let a = currentAttempt {
            endAttempt(url: a.getEndAttemptUrl()) { r, e in completion(nil, r, e) }
        } else {
            fetchLatestRunningAttempt(exam: exam, content: content) { ca, a, error in
                if let ca = ca {
                    self.endExam(url: ca.getEndAttemptUrl()) { r, e in completion(r, r?.assessment, e) }
                } else if let a = a {
                    self.endAttempt(url: a.getEndAttemptUrl()) { r, e in completion(nil, r, e) }
                } else {
                    completion(nil, nil, error)
                }
            }
        }
    }
}
