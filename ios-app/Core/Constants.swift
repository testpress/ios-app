//
//  Constants.swift
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

import Foundation

struct Constants {
    static let APP_NAME = "Testpress iOS App"
    static let BASE_URL = "http://sandbox.testpress.in";
    static let KEYCHAIN_SERVICE_NAME = Bundle.main.bundleIdentifier!
    
    static let LAUNCHED_APP_BEFORE = "launchedAppBefore"
    
    static let TEST_ENGINE = "TestEngine"
    static let EXAM_REVIEW_STORYBOARD = "ExamReview"
    static let LOGIN_VIEW_CONTROLLER = "LoginViewController"
    static let SIGNUP_VIEW_CONTROLLER = "SignUpViewController"
    static let SUCCESS_VIEW_CONTROLLER = "SuccessViewController"
    static let TAB_VIEW_CONTROLLER = "TabViewController"
    static let TEST_ENGINE_VIEW_CONTROLLER = "TestEngineViewController"
    static let QUESTIONS_VIEW_CONTROLLER = "QuestionsViewController"
    static let TEST_REPORT_VIEW_CONTROLLER = "TestReportViewController"
    static let START_EXAM_SCREEN_VIEW_CONTROLLER = "StartExamScreenViewController"
    static let ATTEMPTS_VIEW_CONTROLLER = "AttemptsListViewController"
    static let PAUSED_ATTEMPT_TABLE_VIEW_CELL = "PausedAttemptTableViewCell"
    static let COMPLETED_ATTEMPT_TABLE_VIEW_CELL = "CompletedAttemptTableViewCell"
    static let REVIEW_SOLUTIONS_VIEW_CONTROLLER = "ReviewSolutionsViewController"
    static let REVIEW_QUESTIONS_VIEW_CONTROLLER = "ReviewQuestionsViewController"
    
    static let PAGE = "page"
    static let STATE = "state"
    static let STATE_RUNNING = "Running"
    
    static func getAppVersion() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "\(version).\(build)"
    }
    
}

struct Slug {
    
    static let AVAILABLE = "available"
    static let UPCOMING = "upcoming"
    static let HISTORY = "history"
    
}

