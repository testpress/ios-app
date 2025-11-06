//
//  Exam.swift
//  ios-app
//
//  Copyright © 2017 Testpress. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import ObjectMapper
import RealmSwift
import Foundation

public class Exam: DBModel {
    @objc public dynamic var url: String = "";
    @objc public dynamic var title: String = "";
    @objc public dynamic var examDescription: String = "";
    @objc public dynamic var startDate: String = "";
    @objc public dynamic var endDate: String = "";
    @objc public dynamic var duration: String = "";
    @objc public dynamic var numberOfQuestions: Int = 0;
    @objc public dynamic var negativeMarks: String = "";
    @objc public dynamic var markPerQuestion: String = "";
    @objc public dynamic var templateType: Int = 0;
    @objc public dynamic var allowRetake: Bool = true;
    @objc public dynamic var maxRetakes: Int = 0;
    @objc public dynamic var enableRanks: Bool = false;
    @objc public dynamic var rankPublishingDate: String = "";
    @objc public dynamic var attemptsUrl: String = "";
    @objc public dynamic var attemptsCount: Int = 0;
    @objc public dynamic var pausedAttemptsCount: Int = 0;
    @objc public dynamic var allowPdf: Bool = false;
    @objc public dynamic var allowQuestionPdf: Bool = false;
    @objc public dynamic var created: String = "";
    @objc public dynamic var slug: String = "";
    @objc public dynamic var variableMarkPerQuestion: Bool = false;
    @objc public dynamic var showAnswers: Bool = false;
    @objc public dynamic var commentsCount: Int = 0;
    @objc public dynamic var allowPreemptiveSectionEnding: Bool = false;
    @objc public dynamic var immediateFeedback: Bool = false;
    @objc public dynamic var deviceAccessControl: String = "";
    @objc public dynamic var totalMarks: String = ""
    @objc public dynamic var passPercentage: Double = 0
    @objc public dynamic var showScore: Bool = true
    @objc public dynamic var showPercentile: Bool = true
    @objc public dynamic var studentsAttemptedCount: Int = 0
    @objc public dynamic var isGrowthHackEnabled: Bool = false;
    @objc public dynamic var shareTextForSolutionUnlock: String = "";
    @objc public dynamic var showAnalytics: Bool = false
    @objc public dynamic var enableQuizMode: Bool = false;
    @objc public dynamic var selectedLanguage: Language?
    public var languages = List<Language>()
    @objc public dynamic var examStartUrl: String?
    
    override public static func primaryKey() -> String? {
        return "id"
    }

    
    public override func mapping(map: ObjectMapper.Map) {
        url <- map["url"]
        id <- map["id"]
        title <- map["title"]
        startDate <- map["start_date"]
        endDate <- map["end_date"]
        duration <- map["duration"]
        numberOfQuestions <- map["number_of_questions"]
        negativeMarks <- map["negative_marks"]
        markPerQuestion <- map["mark_per_question"]
        templateType <- map["template_type"]
        allowRetake <- map["allow_retake"]
        maxRetakes <- map["max_retakes"]
        enableRanks <- map["enable_ranks"]
        rankPublishingDate <- map["rank_publishing_date"]
        attemptsUrl <- map["attempts_url"]
        attemptsCount <- map["attempts_count"]
        pausedAttemptsCount <- map["paused_attempts_count"]
        allowPdf <- map["allow_pdf"]
        allowQuestionPdf <- map["allow_question_pdf"]
        created <- map["created"]
        slug <- map["slug"]
        variableMarkPerQuestion <- map["variable_mark_per_question"]
        showAnswers <- map["show_answers"]
        commentsCount <- map["comments_count"]
        allowPreemptiveSectionEnding <- map["allow_preemptive_section_ending"]
        immediateFeedback <- map["immediate_feedback"]
        deviceAccessControl <- map["device_access_control"]
        totalMarks <- map["total_marks"]
        passPercentage <- map["pass_percentage"]
        showScore <- map["show_score"]
        showPercentile <- map["show_percentile"]
        studentsAttemptedCount <- map["students_attempted_count"]
        isGrowthHackEnabled <- map["is_growth_hack_enabled"]
        shareTextForSolutionUnlock <- map["share_text_for_solution_unlock"]
        examDescription <- map["description"]
        showAnalytics <- map["show_analytics"]
        enableQuizMode <- map["enable_quiz_mode"]
        selectedLanguage <- map["selected_language"]
        languages <- (map["languages"], ListTransform<Language>())
        examStartUrl <- map["exam_start_url"]
    }
    
    public func hasMultipleLanguages() -> Bool {
        return languages.count > 1
    }
    
    public func IsExamUsingIBPSTemplate() -> Bool{
        return templateType == 2
    }
    
    public func updateLanguages(with newLanguages: [Language]) {
        DBManager<Exam>().write {
            self.languages.removeAll()
            self.languages.append(objectsIn: newLanguages)
            self.selectedLanguage = newLanguages.first
        }
    }
    
    public func hasStarted() -> Bool {
        guard let date = FormatDate.getDate(from: startDate) else {
            assert(false, "no date from string")
            return true
        }
        return date < Date()
    }
    
    public func hasEnded() -> Bool {
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
    
    public func getNumberOfTimesShared() -> Int {
        return UserDefaults.standard.integer(forKey: getKey())
    }
    
    public func incrementNumberOfTimesShared() {
        UserDefaults.standard.set(getNumberOfTimesShared() + 1, forKey: getKey())
    }
    
    public func getQuestionsURL() -> String {
        return TestpressCourse.shared.baseURL + "/api/v2.4/exams/\(id)/questions/"
    }
}

public struct ExamTemplateType {
    public static let IELTS_TEMPLATE = 12
    public static let CTET_TEMPLATE = 15
}
