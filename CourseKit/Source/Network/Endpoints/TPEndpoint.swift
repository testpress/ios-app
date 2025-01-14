//
//  TPEndpoint.swift
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
import Alamofire

public enum TPEndpoint {
    
    case authenticateUser
    case registerNewUser
    case getExams
    case getQuestions
    case sendHeartBeat
    case saveAnswer
    case endExam
    case loadAttempts
    case resumeAttempt
    case getCourses
    case getChapters
    case getContents
    case getProfile
    case getPosts
    case getForum
    case createForumPost
    case getForumCategories
    case getSubjectAnalytics
    case getAttemptSubjectAnalytics
    case getActivityFeed
    case contentAttempts
    case uploadImage
    case getRank
    case getLeaderboard
    case getTargets
    case getThreats
    case resetPassword
    case getPostCategories
    case authenticateSocialUser
    case getAccessCodeExams
    case examsPath
    case bookmarks
    case bookmarkFolders
    case attemptsPath
    case commentsPath
    case instituteSettings
    case get
    case post
    case put
    case delete
    case registerDevice
    case unRegisterDevice
    case verifyPhoneNumber
    case logout
    case loginActivity
    case logoutDevices
    case userVideos
    case dashboard
    case getSSOUrl
    case getS3PreSignedUrl
    case checkEnforceDataCollectionStatus

    public var method: Alamofire.HTTPMethod {
        switch self {
        case .authenticateUser:
            return .post
        case .registerNewUser:
            return .post
        case .getExams:
            return .get
        case .getQuestions:
            return .get
        case .sendHeartBeat:
            return .put
        case .saveAnswer:
            return .put
        case .endExam:
            return .put
        case .loadAttempts:
            return .get
        case .resumeAttempt:
            return .put
        case .getCourses:
            return .get
        case .getChapters:
            return .get
        case .getContents:
            return .get
        case .getProfile:
            return .get
        case .getPosts:
            return .get
        case .getForum:
            return .get
        case .createForumPost:
            return .post
        case .getForumCategories,
             .getSubjectAnalytics,
             .getAttemptSubjectAnalytics,
             .getRank,
             .getLeaderboard,
             .getTargets,
             .getThreats,
             .getPostCategories,
             .getAccessCodeExams,
             .bookmarks,
             .bookmarkFolders,
             .getActivityFeed,
             .checkEnforceDataCollectionStatus:
            return .get
        case .get:
            return .get
        case .post,
             .resetPassword,
             .authenticateSocialUser,
             .uploadImage,
             .registerDevice,
             .unRegisterDevice,
             .verifyPhoneNumber,
             .logoutDevices,
             .logout,
             .getSSOUrl,
             .getS3PreSignedUrl:
            return .post
        case .put:
            return .put
        case .delete:
            return .delete
        default:
            return .get
        }
    }
    
    public var urlPath: String {
        switch self {
        case .authenticateUser:
            return "/api/v2.3/auth-token/"
        case .registerNewUser:
            return "/api/v2.3/register/"
        case .getExams:
            return "/api/v2.2/exams/"
        case .sendHeartBeat:
            return "heartbeat/"
        case .resumeAttempt:
            return "start/"
        case .endExam:
            return "end/"
        case .getCourses:
            return "/api/v2.4/courses/"
        case .getChapters:
            return "chapters/"
        case .getProfile:
            return "/api/v2.2/me/stats/"
        case .getPosts:
            return "/api/v2.2/posts/"
        case .getForum, .createForumPost:
            return "/api/v2.5/discussions/"
        case .getForumCategories:
            return "/api/v2.3/forum/categories/"
        case .getSubjectAnalytics:
            return "/api/v2.2/analytics/"
        case .getAttemptSubjectAnalytics:
            return "review/subjects/"
        case .getActivityFeed:
            return "/api/v2.4/activities/"
        case .contentAttempts:
            return "/api/v2.2/content_attempts/"
        case .uploadImage:
            return "/api/v2.2/image_upload/"
        case .getRank:
            return "/api/v2.2/me/rank/"
        case .getLeaderboard:
            return "/api/v2.2/leaderboard/"
        case .getTargets:
            return "/api/v2.2/me/targets/"
        case .getThreats:
            return "/api/v2.2/me/threats/"
        case .resetPassword:
            return "/api/v2.2/password/reset/"
        case .getPostCategories:
            return "/api/v2.2/posts/categories/"
        case .authenticateSocialUser:
            return "/api/v2.2/social-auth/"
        case .getAccessCodeExams:
            return "/api/v2.2/access_codes/"
        case .examsPath:
            return "/exams/"
        case .bookmarks:
            return "/api/v2.4/bookmarks/"
        case .bookmarkFolders:
            return "/api/v2.4/folders/"
        case .getContents:
            return "/api/v2.3/contents/"
        case .attemptsPath:
            return "/attempts/"
        case .getQuestions:
            return "/api/v2.2/questions/"
        case .commentsPath:
            return "/comments/"
        case .instituteSettings:
            return "/api/v2.3/settings/"
        case .registerDevice:
            return "/api/v2.2/devices/register/"
        case .unRegisterDevice:
            return "/api/v2.2/devices/unregister/"
        case .verifyPhoneNumber:
            return "/api/v2.2/verify/"
        case .logout:
            return "/api/v2.4/auth/logout/"
        case .loginActivity:
            return "/api/v2.3/me/login_activity/"
        case .logoutDevices:
            return "/api/v2.4/auth/logout_devices/"
        case .userVideos:
            return "/api/v2.4/user_videos/"
        case .dashboard:
            return "/api/v2.4/dashboard/"
        case .getSSOUrl:
            return "/api/v2.3/presigned_sso_url/"
        case .getS3PreSignedUrl:
            return "/api/v2.3/presigned_url/"
        case .checkEnforceDataCollectionStatus:
            return "/api/v2.3/me/check_permission/"
        default:
            return ""
        }
    }
}

public struct TPEndpointProvider {
    public var endpoint: TPEndpoint
    public var url: String
    public var queryParams: [String: String]
    
    public init(_ endpoint: TPEndpoint,
         url: String = "",
         queryParams: [String: String] = [String: String]()) {
        
        self.endpoint = endpoint
        self.url = url
        self.queryParams = queryParams
    }
    
    public init(_ endpoint: TPEndpoint,
         urlPath: String,
         queryParams: [String: String] = [String: String]()) {
        
        let url = urlPath.isEmpty ? "" : TestpressCourse.shared.baseURL + urlPath
        self.init(endpoint, url: url, queryParams: queryParams)
    }
    
    public func getUrl() -> String {
        // If the given url is empty, use base url with url path
        var url = self.url.isEmpty ? TestpressCourse.shared.baseURL + endpoint.urlPath : self.url
        if !queryParams.isEmpty {
            url = url + "?"
            for (i, queryParam) in queryParams.enumerated() {
                let allowedCharacterSet =
                    (CharacterSet(charactersIn: "!*'();@&=+$,/?%#[] ").inverted)
                
                let value = queryParam.value
                    .addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)!
                
                url = url + queryParam.key + "=" + value
                if queryParams.count != (i + 1) {
                    url = url + "&"
                }
            }
        }
        return url
    }
    
    public static func getBookmarkPath(bookmarkId: Int) -> String {
        return TPEndpoint.bookmarks.urlPath + "\(bookmarkId)/"
    }
    
    public static func getBookmarkFolderPath(folderId: Int) -> String {
        return TPEndpoint.bookmarkFolders.urlPath + "\(folderId)/"
    }
    
    public static func getCommentsUrl(questionId: Int) -> String {
        return TestpressCourse.shared.baseURL + TPEndpoint.getQuestions.urlPath + "\(questionId)"
            + TPEndpoint.commentsPath.urlPath
    }
    
    public static func getContentAttemptUrl(contentID: Int) -> String {
        return TestpressCourse.shared.baseURL + TPEndpoint.getContents.urlPath + "\(contentID)" + TPEndpoint.attemptsPath.urlPath
    }
    
    public static func getVideoAttemptPath(attemptID: Int) -> String {
        return TestpressCourse.shared.baseURL + TPEndpoint.userVideos.urlPath + "\(attemptID)/"
    }
    
    public static func getDRMLicenseURL(contentID: Int) -> String {
        return TestpressCourse.shared.baseURL + "/api/v2.5/chapter_contents/\(contentID)/drm_license/"
    }
    
    public static func getCourseDetailUrl(courseId: Int) -> String {
        return TestpressCourse.shared.baseURL + TPEndpoint.getCourses.urlPath + "\(courseId)/"
    }
}
