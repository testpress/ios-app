//
//  CustomTestQuizExamViewModel.swift
//  ios-app
//
//  Created by Prithuvi on 14/11/23.
//  Copyright © 2023 Testpress. All rights reserved.
//

import Foundation

public class CustomTestQuizExamViewModel: QuizExamViewModelDelegate {
    
    private let repository: AttemptRepository
    
    public init(repository: AttemptRepository = AttemptRepository()) {
        self.repository = repository
    }
    
    public func loadQuestions(attemptId: Int, completion: @escaping ([AttemptItem]?, TPError?) -> Void) {
        // We don't have exam object for Custom test so we set default examId as -1
        let examId: Int = -1
        let questionUrl = TestpressCourse.shared.baseURL + "/api/v2.5/attempts/\(attemptId)/questions/"
        repository.loadQuestions(url: questionUrl, examId: examId, attemptId: attemptId, completion: completion)
    }
    

}

public protocol QuizExamViewModelDelegate {
    
    func loadQuestions(attemptId: Int, completion: @escaping([AttemptItem]?, TPError?) -> Void)
    
}
