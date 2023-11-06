//
//  QuizExamViewModel.swift
//  ios-app
//
//  Created by Karthik on 12/05/20.
//  Copyright © 2020 Testpress. All rights reserved.
//

import Foundation


class QuizExamViewModel {
    private let exam: Exam?
    private let content: Content?
    private let repository: AttemptRepository
    
    init(content: Content, repository: AttemptRepository = AttemptRepository()) {
        self.content = content
        self.exam = content.exam!
        self.repository = repository
    }
    
    init(exam: Exam, repository: AttemptRepository = AttemptRepository()) {
        self.exam = exam
        self.repository = repository
        self.content = nil
    }
    
    init(repository: AttemptRepository = AttemptRepository()) {
        self.exam = nil
        self.repository = repository
        self.content = nil
    }
}


extension QuizExamViewModel {
    var title: String {
        return exam!.title
    }
    var noOfQuestions: String {
        return String(exam!.numberOfQuestions)
    }
    var startEndDate: String {
        return FormatDate.format(dateString: exam!.startDate) + " -\n" +
            FormatDate.format(dateString: exam!.endDate)
    }
    var description: String {
        return exam!.examDescription
    }
    var canStartExam: Bool {
        return exam!.deviceAccessControl != "web" && exam!.hasStarted() && !exam!.hasEnded()
    }
    var examInfo: String {
        if(!exam!.hasStarted()) {
            return Strings.CAN_START_EXAM_ONLY_AFTER + FormatDate.format(dateString: exam!.startDate)
        } else if exam!.hasEnded() {
            return Strings.EXAM_ENDED
        }
        return ""
    }
    
    public func loadContentAttempt(completion: @escaping(ContentAttempt?, TPError?) -> Void) {
        if (content == nil) {
            debugPrint("Content is nil")
        }
        repository.loadContentAttempt(attemptsUrl: content!.getAttemptsUrl(), completion: completion)
    }
    
    public func loadQuestions(attemptId: Int, completion: @escaping([AttemptItem]?, TPError?) -> Void) {
        let examId: Int
        if exam == nil {
            examId = -1
        } else {
            examId = exam!.id
        }
        let questionUrl = Constants.BASE_URL + "/api/v2.5/attempts/\(attemptId)/questions/"
        repository.loadQuestions(url: questionUrl, examId: examId, attemptId: attemptId, completion: completion)
    }
    
}
