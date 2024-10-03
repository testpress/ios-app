//
//  Exam.swift
//  ios-app
//
//  Created by Testpress on 03/10/24.
//  Copyright © 2024 Testpress. All rights reserved.
//

import Foundation
import CourseKit

extension Exam {
    func hasStarted() -> Bool {
        guard let date = FormatDate.getDate(from: startDate) else {
            assert(false, "no date from string")
            return true
        }
        return date < Date()
    }
    
    func hasEnded() -> Bool {
        if endDate == nil || endDate == "" {
            return false
        }
        guard let date = FormatDate.getDate(from: endDate) else {
            assert(false, "no date from string")
            return false
        }
        return date < Date()
    }
    
    private func getKey() -> String {
        let id = String(self.id)
        return "\(id)_SHARE_TO_UNLOCK"
    }
    
    func getNumberOfTimesShared() -> Int {
        return UserDefaults.standard.integer(forKey: getKey())
    }
    
    func incrementNumberOfTimesShared() {
        UserDefaults.standard.set(getNumberOfTimesShared() + 1, forKey: getKey())
    }
    
    func getQuestionsURL() -> String {
        return Constants.BASE_URL + "/api/v2.4/exams/\(id)/questions/"
    }
}
