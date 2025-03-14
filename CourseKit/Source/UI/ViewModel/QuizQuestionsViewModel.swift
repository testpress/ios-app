//
//  QuizQuestionsViewModel.swift
//  ios-app
//
//  Created by Karthik on 26/05/20.
//  Copyright © 2020 Testpress. All rights reserved.
//

import Foundation


public class QuizQuestionsViewModel {
    private let repository: AttemptItemRepository
    private let attempt: Attempt?
    private let contentAttempt: ContentAttempt?

    public init(contentAttempt: ContentAttempt?, repository: AttemptItemRepository = AttemptItemRepository()) {
        self.repository = repository
        self.contentAttempt = contentAttempt
        self.attempt = contentAttempt?.assessment
    }
    
    public init(repository: AttemptItemRepository = AttemptItemRepository()) {
        self.repository = repository
        self.contentAttempt = nil
        self.attempt = nil
    }
    
    public init(attempt: Attempt?, repository: AttemptItemRepository = AttemptItemRepository()) {
        self.repository = repository
        self.contentAttempt = nil
        self.attempt = attempt
    }
    
    public func getFirstUnAttemptedItemIndex() -> Int {
        assert(attempt != nil, "Attempt cannot be nil")
        return repository.getIndexOfFirstUnAttemptedItem(attemptId: attempt!.id)
    }
    
    public func getAttemptItem(id: Int) -> AttemptItem {
        return repository.getAttemptItem(id: id)
    }
    
    public func endExam(completion: @escaping(ContentAttempt?, TPError?) -> Void) {
        assert(contentAttempt != nil, "Content Attempt cannot be null")
        repository.endExam(url: contentAttempt!.getEndAttemptUrl(), completion: completion)
    }
    
    public func endAttempt(completion: @escaping(Attempt?, TPError?) -> Void) {
        assert(attempt != nil, "Attempt cannot be nil")
        repository.endAttempt(url: attempt!.getEndAttemptUrl(), completion: completion)
    }
    
    public func submitAnswer(id: Int) {
        repository.submitAnswer(id: id)
    }
    
    public func selectAnswer(id: Int, selectedOptions: [Int] = [], shortText: String = "") -> AttemptItem {
        return repository.selectAnswer(id: id, selectedOptions: selectedOptions,shortText: shortText.trim())
    }
}
