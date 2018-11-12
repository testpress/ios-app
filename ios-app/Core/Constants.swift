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
    static let BASE_URL = "https://ariseacademy.testpress.in";
    
    static let APP_APPLE_ID = "1441934245"
    
    static let APP_SHARE_MESSAGE = "Good app to prepare for MBBS, USMLE, FMGE classes. Get it at http://itunes.apple.com/app/id" + APP_APPLE_ID
    
    static let APP_STORE_LINK = "itms-apps://itunes.apple.com/app/id" + APP_APPLE_ID
    
    static let KEYCHAIN_SERVICE_NAME = Bundle.main.bundleIdentifier!
    
    static let LAUNCHED_APP_BEFORE = "launchedAppBefore"
    
    static let TROPHIES_ENABLED = true
    static let BOOKMARKS_ENABLED = true
    
    static let TEST_ENGINE = "TestEngine"
    static let EXAM_REVIEW_STORYBOARD = "ExamReview"
    static let LOGIN_VIEW_CONTROLLER = "LoginViewController"
    static let SIGNUP_VIEW_CONTROLLER = "SignUpViewController"
    static let SUCCESS_VIEW_CONTROLLER = "SuccessViewController"
    static let TAB_VIEW_CONTROLLER = "TabViewController"
    static let EXAMS_TAB_VIEW_CONTROLLER = "ExamsTabViewController"
    static let TEST_ENGINE_VIEW_CONTROLLER = "TestEngineViewController"
    static let QUESTIONS_VIEW_CONTROLLER = "QuestionsViewController"
    static let TEST_REPORT_VIEW_CONTROLLER = "TestReportViewController"
    static let START_EXAM_SCREEN_VIEW_CONTROLLER = "StartExamScreenViewController"
    static let ATTEMPTS_VIEW_CONTROLLER = "AttemptsListViewController"
    static let PAUSED_ATTEMPT_TABLE_VIEW_CELL = "PausedAttemptTableViewCell"
    static let COMPLETED_ATTEMPT_TABLE_VIEW_CELL = "CompletedAttemptTableViewCell"
    static let REVIEW_SOLUTIONS_VIEW_CONTROLLER = "ReviewSolutionsViewController"
    static let REVIEW_QUESTIONS_VIEW_CONTROLLER = "ReviewQuestionsViewController"
    static let REVIEW_QUESTION_LIST_VIEW_CONTROLLER = "ReviewQuestionListViewController"
    static let QUESTION_LIST_VIEW_CONTROLLER = "QuestionListViewController"
    static let TEST_ENGINE_NAVIGATION_CONTROLLER = "TestEngineNavigationController"
    static let REVIEW_NAVIGATION_VIEW_CONTROLLER = "ReviewNavigationViewController"
    static let COURSE_LIST_VIEW_CELL = "CourseTableViewCell"
    static let CHAPTER_CONTENT_STORYBOARD = "ChapterContent"
    static let CHAPTERS_VIEW_CONTROLLER = "ChaptersViewController"
    static let CHAPTER_COLLECTION_VIEW_CELL = "ChapterCollectionViewCell"
    static let CONTENTS_LIST_NAVIGATION_CONTROLLER = "ContentsListNavigationController"
    static let CONTENT_TABLE_VIEW_CELL = "ContentsTableViewCell"
    static let CONTENT_DETAIL_PAGE_VIEW_CONTROLLER = "ContentDetailPageViewController"
    static let HTML_CONTENT_VIEW_CONTROLLER = "HtmlContentViewController"
    static let ATTACHMENT_DETAIL_VIEW_CONTROLLER = "AttachmentDetailViewController"
    static let CONTENT_START_EXAM_VIEW_CONTROLLER = "ContentStartExamViewController"
    static let CONTENT_EXAM_ATTEMPS_TABLE_VIEW_CONTROLLER = "ContentExamAttemptsTableViewController"
    static let POST_TABLE_VIEW_CELL = "PostTableViewCell"
    static let POST_STORYBOARD = "Post"
    static let POST_DETAIL_VIEW_CONTROLLER = "PostDetailViewController"
    static let POST_CREATION_VIEW_CONTROLLER = "PostCreationViewController"
    static let FORUM_TABLE_VIEW_CELL = "ForumTableViewCell"
    static let SUBJECT_ANALYTICS_TAB_VIEW_CONTROLLER = "SubjectAnalyticsTabViewController"
    static let INDIVIDUAL_SUBJECT_ANALYTICS_VIEW_CONTROLLER = "IndividualSubjectAnalyticsViewController"
    static let OVERALL_SUBJECT_ANALYTICS_VIEW_CONTROLLER = "OverallSubjectAnalyticsViewController"
    static let INDIVIDUAL_SUBJECT_ANALYTICS_COUNT_CELL = "IndividualSubjectAnalyticsCountCell"
    static let INDIVIDUAL_SUBJECT_ANALYTICS_GRAPH_CELL = "IndividualSubjectAnalyticsGraphCell"
    static let TIME_ANALYTICS_HEADER_VIEW_CELL = "TimeAnalyticsHeaderViewCell"
    static let TIME_ANALYTICS_QUESTION_CELL = "TimeAnalyticsQuestionCell"
    static let TIME_ANALYTICS_TABLE_VIEW_CONTROLLER = "TimeAnalyticsTableViewController"
    static let ACTIVITY_FEED_TABLE_VIEW_CELL = "ActivityFeedTableViewCell"
    static let TROPHIES_ACHIEVED_VIEW_CONTROLLER = "TrophiesAchievedViewController"
    static let LEADERBOARD_TABLE_VIEW_CONTROLLER = "LeaderboardTableViewController"
    static let LEADERBOARD_TABLE_VIEW_CELL = "LeaderboardTableViewCell"
    static let PROFILE_VIEW_CONTROLLER = "ProfileViewController"
    static let MAIN_STORYBOARD = "Main"
    static let RESET_PASSWORD_VIEW_CONTROLLER = "ResetPasswordViewController"
    static let POST_CATEGORIES_TABLE_VIEW_CELL = "PostCategoriesTableViewCell"
    static let POSTS_LIST_NAVIGATION_CONTROLLER = "PostsListNavigationController"
    static let ACCESS_CODE_EXAMS_NAVIGATION_CONTROLLER = "AccessCodeExamsNavigationController"
    static let BOOKMARKS_TABLE_VIEW_CELL = "BookmarksTableViewCell"
    static let BOOKMARKS_LIST_NAVIGATION_CONTROLLER = "BookmarksListNavigationController"
    static let BOOKMARKS_STORYBOARD = "Bookmarks"
    static let BOOKMARKS_DETAIL_PAGE_VIEW_CONTROLLER = "BookmarksDetailPageViewController"
    static let BOOKMARKS_LIST_VIEW_CONTROLLER = "BookmarksListViewController"
    static let BOOKMARKS_TABLE_VIEW_CONTROLLER = "BookmarksTableViewController"
    static let BOOKMARKED_QUESTION_VIEW_CONTROLLER = "BookmarkedQuestionViewController"
    static let BOOKMARK_FOLDER_NAVIGATION_CONTROLLER = "BookmarkFolderNavigationController"
    static let BOOKMARK_FOLDER_TABLE_VIEW_CELL = "BookmarkFolderTableViewCell"
    
    static let PAGE = "page"
    static let PAGE_SIZE = "page_size"
    static let PARENT = "parent"
    static let STATE = "state"
    static let STATE_RUNNING = "Running"
    static let ORDER = "order"
    static let SINCE = "since"
    static let UNTIL = "until"
    static let FILTER = "filter"
    static let ADMIN = "admin"
    static let CATEGORY = "category"
    static let STARRED = "starred"
    static let ACCESS_CODE = "access_code"
    static let UNCATEGORIZED = "Uncategorized"
    
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

