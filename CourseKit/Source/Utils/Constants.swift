//
//  Constants.swift
//  CourseKit
//
//  Created by Testpress on 04/10/24.
//  Copyright © 2024 Testpress. All rights reserved.
//

import Foundation

public struct Constants {
    public static let APP_APPLE_ID = "1434052944"
    
    public static let APP_SHARE_MESSAGE = "Good app to prepare for online exams. Get it at http://itunes.apple.com/app/id" + APP_APPLE_ID
    
    public static let APP_STORE_LINK = "itms-apps://itunes.apple.com/app/id" + APP_APPLE_ID
    
    public static let KEYCHAIN_SERVICE_NAME = Bundle.main.bundleIdentifier!
    
    public static let LAUNCHED_APP_BEFORE = "launchedAppBefore"
    
    public static let TROPHIES_ENABLED = true
    public static let BOOKMARKS_ENABLED = true
    
    public static let TEST_ENGINE = "TestEngine"
    public static let EXAM_REVIEW_STORYBOARD = "ExamReview"
    public static let LOGIN_VIEW_CONTROLLER = "LoginViewController"
    public static let SIGNUP_VIEW_CONTROLLER = "SignUpViewController"
    public static let SUCCESS_VIEW_CONTROLLER = "SuccessViewController"
    public static let TAB_VIEW_CONTROLLER = "TabViewController"
    public static let EXAMS_TAB_VIEW_CONTROLLER = "ExamsTabViewController"
    public static let TEST_ENGINE_VIEW_CONTROLLER = "TestEngineViewController"
    public static let QUESTIONS_VIEW_CONTROLLER = "QuestionsViewController"
    public static let TEST_REPORT_VIEW_CONTROLLER = "TestReportViewController"
    public static let START_EXAM_SCREEN_VIEW_CONTROLLER = "StartExamScreenViewController"
    public static let ATTEMPTS_VIEW_CONTROLLER = "AttemptsListViewController"
    public static let PAUSED_ATTEMPT_TABLE_VIEW_CELL = "PausedAttemptTableViewCell"
    public static let COMPLETED_ATTEMPT_TABLE_VIEW_CELL = "CompletedAttemptTableViewCell"
    public static let REVIEW_SOLUTIONS_VIEW_CONTROLLER = "ReviewSolutionsViewController"
    public static let REVIEW_QUESTIONS_VIEW_CONTROLLER = "ReviewQuestionsViewController"
    public static let REVIEW_QUESTION_LIST_VIEW_CONTROLLER = "ReviewQuestionListViewController"
    public static let QUESTION_LIST_VIEW_CONTROLLER = "QuestionListViewController"
    public static let TEST_ENGINE_NAVIGATION_CONTROLLER = "TestEngineNavigationController"
    public static let REVIEW_NAVIGATION_VIEW_CONTROLLER = "ReviewNavigationViewController"
    public static let COURSE_LIST_VIEW_CELL = "CourseTableViewCell"
    public static let CHAPTER_CONTENT_STORYBOARD = "Course"
    public static let CHAPTERS_VIEW_CONTROLLER = "ChaptersViewController"
    public static let CHAPTER_COLLECTION_VIEW_CELL = "ChapterCollectionViewCell"
    public static let CONTENTS_LIST_NAVIGATION_CONTROLLER = "ContentsListNavigationController"
    public static let CONTENT_TABLE_VIEW_CELL = "ContentsTableViewCell"
    public static let CONTENT_DETAIL_PAGE_VIEW_CONTROLLER = "ContentDetailPageViewController"
    public static let HTML_CONTENT_VIEW_CONTROLLER = "HtmlContentViewController"
    public static let ATTACHMENT_DETAIL_VIEW_CONTROLLER = "AttachmentDetailViewController"
    public static let VIDEO_CONTENT_VIEW_CONTROLLER = "VideoContentViewController"
    public static let VIDEO_CONFERENCE_VIEW_CONTROLLER = "VideoConferenceViewController"
    public static let ZOOM_MEET_VIEW_CONTROLLER = "ZoomMeetViewController"
    public static let CONTENT_START_EXAM_VIEW_CONTROLLER = "ContentStartExamViewController"
    public static let START_QUIZ_EXAM_VIEW_CONTROLLER = "StartQuizExamViewController"
    public static let QUIZ_EXAM_VIEW_CONTROLLER = "QuizExamViewController"
    public static let QUIZ_QUESTION_VIEW_CONTROLLER = "QuizQuestionViewController"
    public static let QUIZ_QUESTIONS_PAGE_VIEW_CONTROLLER = "QuizQuestionsPageViewController"
    public static let LIVE_STREAM_VIEW_CONTROLLER = "LiveStreamContentViewController"
    
    public static let CONTENT_EXAM_ATTEMPS_TABLE_VIEW_CONTROLLER = "ContentExamAttemptsTableViewController"
    public static let POST_TABLE_VIEW_CELL = "PostTableViewCell"
    public static let POST_STORYBOARD = "Post"
    public static let POST_DETAIL_VIEW_CONTROLLER = "PostDetailViewController"
    public static let POST_CREATION_VIEW_CONTROLLER = "PostCreationViewController"
    public static let FORUM_TABLE_VIEW_CELL = "ForumTableViewCell"
    public static let SUBJECT_ANALYTICS_TAB_VIEW_CONTROLLER = "SubjectAnalyticsTabViewController"
    public static let INDIVIDUAL_SUBJECT_ANALYTICS_VIEW_CONTROLLER = "IndividualSubjectAnalyticsViewController"
    public static let OVERALL_SUBJECT_ANALYTICS_VIEW_CONTROLLER = "OverallSubjectAnalyticsViewController"
    public static let INDIVIDUAL_SUBJECT_ANALYTICS_COUNT_CELL = "IndividualSubjectAnalyticsCountCell"
    public static let INDIVIDUAL_SUBJECT_ANALYTICS_GRAPH_CELL = "IndividualSubjectAnalyticsGraphCell"
    public static let TIME_ANALYTICS_HEADER_VIEW_CELL = "TimeAnalyticsHeaderViewCell"
    public static let TIME_ANALYTICS_QUESTION_CELL = "TimeAnalyticsQuestionCell"
    public static let TIME_ANALYTICS_TABLE_VIEW_CONTROLLER = "TimeAnalyticsTableViewController"
    public static let ACTIVITY_FEED_TABLE_VIEW_CELL = "ActivityFeedTableViewCell"
    public static let TROPHIES_ACHIEVED_VIEW_CONTROLLER = "TrophiesAchievedViewController"
    public static let LEADERBOARD_TABLE_VIEW_CONTROLLER = "LeaderboardTableViewController"
    public static let LEADERBOARD_TABLE_VIEW_CELL = "LeaderboardTableViewCell"
    public static let PROFILE_VIEW_CONTROLLER = "ProfileViewController"
    public static let MAIN_STORYBOARD = "Main"
    public static let RESET_PASSWORD_VIEW_CONTROLLER = "ResetPasswordViewController"
    public static let POST_CATEGORIES_TABLE_VIEW_CELL = "PostCategoriesTableViewCell"
    public static let POSTS_LIST_NAVIGATION_CONTROLLER = "PostsListNavigationController"
    public static let ACCESS_CODE_EXAMS_NAVIGATION_CONTROLLER = "AccessCodeExamsNavigationController"
    public static let BOOKMARKS_TABLE_VIEW_CELL = "BookmarksTableViewCell"
    public static let BOOKMARKS_LIST_NAVIGATION_CONTROLLER = "BookmarksListNavigationController"
    public static let BOOKMARKS_STORYBOARD = "Bookmarks"
    public static let BOOKMARKS_DETAIL_PAGE_VIEW_CONTROLLER = "BookmarksDetailPageViewController"
    public static let BOOKMARKS_LIST_VIEW_CONTROLLER = "BookmarksListViewController"
    public static let BOOKMARKS_TABLE_VIEW_CONTROLLER = "BookmarksTableViewController"
    public static let BOOKMARKED_QUESTION_VIEW_CONTROLLER = "BookmarkedQuestionViewController"
    public static let BOOKMARK_FOLDER_NAVIGATION_CONTROLLER = "BookmarkFolderNavigationController"
    public static let BOOKMARK_FOLDER_TABLE_VIEW_CELL = "BookmarkFolderTableViewCell"
    public static let VERIFY_PHONE_VIEW_CONTROLLER = "VerifyPhoneViewController"
    public static let SHARE_TO_UNLOCK_VIEW_CONTROLLER = "ShareToUnlockViewController"
    public static let LOGIN_ACTIVITY_VIEW_CONTROLLER = "LoginActivityViewController"
    public static let PDF_VIEW_CONTROLLER = "PDFViewController"
    public static let OFFLINE_DOWNLOADS_VIEW_CONTROLLERS = "OfflineDownloadsViewController"

    
    public static let PAGE = "page"
    public static let PAGE_SIZE = "page_size"
    public static let PARENT = "parent"
    public static let STATE = "state"
    public static let STATE_RUNNING = "Running"
    public static let ORDER = "order"
    public static let SINCE = "since"
    public static let UNTIL = "until"
    public static let FILTER = "filter"
    public static let ADMIN = "admin"
    public static let CATEGORY = "category"
    public static let STARRED = "starred"
    public static let ACCESS_CODE = "access_code"
    public static let UNCATEGORIZED = "Uncategorized"
    public static let DEVICE_TOKEN = "device_token"
    public static let FCM_TOKEN = "fcm_token"
    public static let REGISTER_DEVICE_TOKEN = "register_device_token"
    
    //    ERROR_CODES
    public static let MULTIPLE_LOGIN_RESTRICTION_ERROR_CODE = "parallel_login_restriction"
    public static let MAX_LOGIN_LIMIT_EXCEEDED = "max_login_exceeded"

    
    public static func getAppVersion() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "\(version).\(build)"
    }
    
    public static func getAppName() -> String {
        return Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? ""
    }
}

public struct Slug {
    
    public static let AVAILABLE = "available"
    public static let UPCOMING = "upcoming"
    public static let HISTORY = "history"
    
}

