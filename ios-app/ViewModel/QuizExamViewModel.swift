//
//  QuizExamViewModel.swift
//  ios-app
//
//  Created by Karthik on 12/05/20.
//  Copyright © 2020 Testpress. All rights reserved.
//

import Foundation


class QuizExamViewModel {
    private let exam: Exam
    
    init(exam: Exam) {
        self.exam = exam
    }
}


extension QuizExamViewModel {
    var title: String {
        return exam.title
    }
    var noOfQuestions: String {
        return String(exam.numberOfQuestions)
    }
    var startEndDate: String {
        return FormatDate.format(dateString: exam.startDate) + " -\n" +
            FormatDate.format(dateString: exam.endDate)
    }
    var description: String {
        return exam.examDescription
    }
    var canStartExam: Bool {
        return exam.deviceAccessControl != "web" && exam.hasStarted() && !exam.hasEnded()
    }
    var examInfo: String {
        if(!exam.hasStarted()) {
            return Strings.CAN_START_EXAM_ONLY_AFTER + FormatDate.format(dateString: exam.startDate)
        } else if exam.hasEnded() {
            return Strings.EXAM_ENDED
        }
        return ""
    }
    
}
