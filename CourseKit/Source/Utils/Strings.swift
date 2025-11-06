//
//  Strings.swift
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

public struct Strings {

    public static let YES = "Yes"
    public static let NO = "No"
    public static let OK = "OK"
    public static let TRY_AGAIN = "Try Again"
    
    public static let NETWORK_ERROR = "Network Error"
    public static let NO_INTERNET_CONNECTION = "No Internet Connection"
    public static let PLEASE_CHECK_INTERNET_CONNECTION = "Please check your internet connection & try again."
    public static let AUTHENTICATION_FAILED = "Authentication failed"
    public static let PLEASE_LOGIN = "Please login to see this"
    public static let LOADING_FAILED = "Loading Failed"
    public static let SOMETHIGN_WENT_WRONG = "Some thing went wrong, please try again later."
    
    public static let WRONG_CREDENTIALS = "Wrong Credentials"
    public static let USERNAME_PASSWORD_NOT_MATCHED = "Username & Password didn't match. Please try again."
    
    public static let NO_ITEMS_EXIST = "No items exist"
    public static let NO_CONTENTS_EXIST = "Empty Course"
    public static let NO_EXAMS = "Learning can't wait"
    public static let NO_AVAILABLE_EXAM = "Looks like you don't have any active exams. Contact administrator for more details."
    public static let NO_UPCOMING_EXAM = "Looks like you don't have any upcoming exams."
    public static let NO_ATTEMPTED_EXAM = "Looks like you have not attempted any exams till now."
    public static let NO_QUESTIONS = "No Questions Found"
    public static let NO_QUESTIONS_DESCRIPTION = "No questions added to this exam, try after some time."
    
    public static let NO_COURSES = "Learning can't wait"
    public static let NO_COURSE_DESCRIPTION = "Looks like you don’t have any active courses. Kindly contact admin."
    public static let NO_CHAPTER_DESCRIPTION = "The course doesn't have any chapters or contents"
    public static let NO_CONTENT_DESCRIPTION = "Looks like contents not available. Check back later."
    
    public static let NO_POSTS = "Breaking news!"
    public static let NO_POSTS_DESCRIPTION = "Looks like the admin didn’t update this news page yet. Check back in a bit?"
    
    public static let NO_FORUM_POSTS = "Discuss with folks!"
    public static let NO_FORUM_POSTS_DESCRIPTION = "Looks like no one created a discussion yet. Create a discussion about your doubt or share your knowledge?"
    
    public static let NO_ACTIVITIES = "No Recent Activities!"
    public static let NO_ADMIN_ACTIVITIES_DESCRIPTION = "Looks like the admin didn’t update this page yet. Check back in a bit?"
    
    public static let NO_LEADERBOARD_ITEMS = "Toppers under progress"
    public static let NO_LEADERBOARD_ITEMS_DESCRIPTION = "We are yet to update the leaderboard list. Check back later?"
    
    public static let RESUME_EXAM = "Resume Exam"
    
    public static let CORRECT_ANSWER = "Correct Answer:"
    public static let EXPLANATION = "Explanation:"
    public static let SUBJECT_HEADING = "Subject:"
    public static let COMMENTS = "Comments"
    
    public static let LOADING_QUESTIONS = "Loading questions"
    public static let LOADING_SECTION_QUESTIONS = "Loading section questions\n\n"
    
    public static let LOADING = "Loading…"
    public static let PLEASE_WAIT = "Please wait"
    
    public static let AVAILABLE = "AVAILABLE"
    public static let UPCOMING = "UPCOMING"
    public static let HISTORY = "HISTORY"
    
    public static let LOGIN = "Login"
    
    public static let EXIT_EXAM = "Exit Exam"
    public static let END_MESSAGE = "Are you sure? you can pause the exam & resume later before the end date."
    public static let PAUSE_MESSAGE = "Are you sure? Want to Pause the exam & resume later before the end date."
    
    public static let PAUSE = "Pause"
    public static let END = "End"
    public static let CANCEL = "Cancel"
    
    public static let ENTER_VALID_EMAIL = "Please enter a valid email address"
    public static let ENTER_VALID_USERNAME = "Use only alphabets or numbers"
    public static let ENTER_VALID_PHONE_NUMBER = "Please enter valid phone number"
    public static let PASSWORD_MUST_HAVE_SIX_CHARACTERS = "Require at least 6 digits"
    public static let PASSWORD_NOT_MATCH = "Passwords not matching"
    
    public static let ACTIVATION_MAIL_SENT = "An activation email has been sent. Please check your email and click on the link to activate your account."
    
    public static let YOU_MADE_IT = "You Made It!"
    public static let POST_CREATED_DESCRIPTION = "You have successfully created a new discussion, wait for your folks response"
    
    public static let NO_ANALYTICS = "No Analytics Data!"
    public static let NO_SUBJECT_ANALYTICS_DESCRIPTION = "No subjects available to analyse"
    
    public static let OVERALL_SUBJECTS_ANALYTICS = "OVERALL"
    public static let INDIVIDUAL_SUBJECTS_ANALYTICS = "INDIVIDUAL SUBJECTS"
    
    public static let LOGOUT = "Log Out"
    public static let LOGOUT_CONFIRM_MESSAGE = "Are you sure want to log out?"
    
    public static let LOAD_MORE_COMMENTS = "Load previous comments"
    public static let LOAD_COMMENTS = "Load comments"
    public static let LOAD_NEW_COMMENTS = "Load new comments"
    
    public static let PHOTO_LIBRARY = "Photo Library"
    public static let CAMERA = "Camera"
    public static let INVALID_IMAGE = "Invalid Image"
    public static let YOUR_DEVAICE_NOT_SUPPORTED = "Your device is not supported"
    public static let NEEDS_PERMISSION_TO_ACCESS = "Needs permission to access "
    public static let GO_TO_SETTINGS = "Go to Settings to enable the permission"
    public static let SETTINGS = "Settings"
    
    public static let LEADERBOARD = "LEADERBOARD"
    public static let TARGETS_AND_THREATS = "TARGETS / THREATS"
    
    public static let EXAM_ENDED = "This exam has ended"
    public static let CAN_START_EXAM_ONLY_AFTER = "You can attempt this exam only after \n"
    public static let SCORE_GOOD_IN_PREVIOUS = "You need to get good score in your previous test to attempt this."
    
    public static let RESET_PASSWORD_MAIL_SENT = "We have sent you an email with a link to reset your password.  Please check your email and click the link to continue."
    
    public static let ARTICLES = "Articles"
    
    public static let INVALID_ACCESS_CODE = "Invalid Access Code"
    
    public static let INVALID_FOLDER_NAME = "Folder name not allowed"
    public static let BOOKMARK_MOVED_SUCCESSFULLY = "Bookmark moved successfully"
    public static let BOOKMARK_DELETED_SUCCESSFULLY = "Bookmark deleted successfully"
    public static let ENTER_FOLDER_NAME = "Enter Folder Name"
    public static let RENAME_FOLDER = "Rename Folder"
    public static let FOLDER_UPDATED_SUCCESSFULLY = "Folder updated successfully"
    public static let ARE_YOU_SURE = "Are you sure?"
    public static let WANT_TO_DELETE_FOLDER = "Do you want to delete this folder?"
    public static let FOLDER_DELETED_SUCCESSFULLY = "Folder deleted successfully"
    public static let WANT_TO_DELETE_BOOKMARK = "Do you want to delete this bookmark?"
    public static let CREATE = "Create"
    public static let UDPATE = "Update"
    public static let DELETE = "Delete"
    
    public static let ALL_BOOKMARKS = "All Bookmarks"
    public static let BOOKMARKS = "Bookmarks"
    public static let NO_BOOKMARKS = "No bookmarks added yet"
    public static let NO_BOOKMARKS_DESCRIPTION = "You can bookmark stuff like Questions, Articles, Videos and Files you see in the courses you’ve opted for."
    
    public static let BOOKMARK_THIS = "Bookmark this"
    public static let REMOVE_BOOKMARK = "Remove Bookmark"
    
    public static let EXAM_PAUSED_CHECK_INTERNET = "Exam is paused, Please check your internet connection & resume again."
    public static let EXAM_PAUSED_CHECK_INTERNET_TO_END = "Exam is paused, Please check your internet connection & try again."
    
    public static let CANNOT_SWITCH_SECTION = "Can\'t Switch Section!"
    public static let CANNOT_SWITCH_IN_FIRST_ATTEMPT = "Section is locked. Switching section is not allowed."
    public static let ALREADY_SUBMITTED = "You have already submitted this section."
    public static let SWITCH_SECTION = "Switch Section?"
    public static let SWITCH_SECTION_MESSAGE = "Are you sure want to move to the next section? You won\'t be able to switch back to this section."
    public static let ATTEMPT_SECTION_IN_ORDER = "You need to attempt sections in order."
    public static let END_SECTION = "End current section"
    public static let ENDING_SECTION = "Ending current section\n\n"
    public static let ENDING_EXAM = "Ending exam\n\n"
    public static let STARTING_SECTION = "Starting next section\n\n"
    public static let SAVING_LAST_CHANGE = "Saving your last change\n\n"
    
    public static let YOUR_ANSWER = "Your Answer:"
    public static let MARKS_AWARDED = "Marks Awarded:"
    public static let NOTE = "Note:"
    public static let CASE_INSENSITIVE = "Answers are case insensitive"
    public static let CASE_SENSITIVE = "Answers are case sensitive"
    
    public static let PARALLEL_LOGIN_RESTRICTION_INFO = "Note : Admin has restricted parallel logged in devices to "
    public static let ACCOUNT_LOCKED = "Account Locked"
    public static let MAX_LOGIN_EXCEEDED_ERROR_MESSAGE = "Your account has been locked as it has exceeded maximum devices it can be used."
    public static let ACCOUNT_UNLOCK_INFO = "Your account will automatically get unlocked within "

    public static let LIVE_ENDED_WITH_RECORDING_DESC = "The live stream has come to an end. Stay tuned, we\'ll have the recording ready for you shortly."
    public static let LIVE_ENDED_WITHOUT_RECORDING_DESC = "The live stream has ended. See you at the next one!"
    public static let LIVE_NOT_STARTED_DESC = "Hang tight! The live stream will kick off in a few moments."
}
