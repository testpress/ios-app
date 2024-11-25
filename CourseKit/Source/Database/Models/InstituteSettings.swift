//
//  InstituteSettings.swift
//  ios-app
//
//  Copyright © 2018 Testpress. All rights reserved.
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
import Foundation

public class InstituteSettings: DBModel {
    
    @objc public dynamic var baseUrl: String = ""
    @objc public dynamic var verificationMethod: String = ""
    @objc public dynamic var allowSignup: Bool = false
    @objc public dynamic var forceStudentData: Bool = false
    @objc public dynamic var removeTpBranding: Bool = false
    @objc public dynamic var showGameFrontend: Bool = false
    @objc public dynamic var url: String = ""
    @objc public dynamic var coursesEnabled: Bool = false
    @objc public dynamic var coursesEnableGamification: Bool = false
    @objc public dynamic var coursesLabel: Bool = false
    @objc public dynamic var postsEnabled: Bool = false
    @objc public dynamic var postsLabel: String = ""
    @objc public dynamic var storeEnabled: Bool = false
    @objc public dynamic var documentsEnabled: Bool = false
    @objc public dynamic var documentsLabel: String = ""
    @objc public dynamic var storeLabel: String = ""
    @objc public dynamic var resultsEnabled: Bool = false
    @objc public dynamic var dashboardEnabled: Bool = false
    @objc public dynamic var facebookLoginEnabled: Bool = false
    @objc public dynamic var googleLoginEnabled: Bool = false
    @objc public dynamic var commentsVotingEnabled: Bool = false
    @objc public dynamic var bookmarksEnabled: Bool = false
    @objc public dynamic var forumEnabled: Bool = false
    @objc public dynamic var twilioEnabled: Bool = false
    @objc public dynamic var activityFeedEnabled: Bool = false
    @objc public dynamic var enableParallelLoginRestriction: Bool = false
    @objc public dynamic var maxParallelLogins: Int = 0
    @objc public dynamic var lockoutLimit: String = ""
    @objc public dynamic var cooloffTime: String = ""
    @objc public dynamic var appToolbarLogo: String = ""
    @objc public dynamic var customRegistrationEnabled: Bool = false
    @objc public dynamic var fairplayCertificateUrl: String = ""
    @objc public dynamic var isHelpdeskEnabled: Bool = false
    @objc public dynamic var sentryDSN: String = ""
    @objc public dynamic var disableForgotPassword: Bool = false
    @objc public dynamic var enableCustomTest: Bool = false
    @objc public dynamic var AllowScreenShotInApp: Bool = false
    @objc public dynamic var isVideoDownloadEnabled: Bool = false
    @objc public dynamic var salesforceSdkEnabled: Bool = false
    @objc public dynamic var salesforceMcApplicationId: String? = nil
    @objc public dynamic var salesforceMcAccessToken: String? = nil
    @objc public dynamic var salesforceFcmSenderId: String? = nil
    @objc public dynamic var salesforceMarketingCloudUrl: String? = nil
    @objc public dynamic var salesforceMid: String? = nil

    public override func mapping(map: ObjectMapper.Map) {
        verificationMethod <- map["verification_method"]
        allowSignup <- map["allow_signup"]
        forceStudentData <- map["force_student_data"]
        removeTpBranding <- map["remove_tp_branding"]
        url <- map["url"]
        showGameFrontend <- map["show_game_frontend"]
        coursesEnabled <- map["courses_enabled"]
        coursesEnableGamification <- map["courses_enable_gamification"]
        coursesLabel <- map["courses_label"]
        postsEnabled <- map["posts_enabled"]
        postsLabel <- map["posts_label"]
        storeEnabled <- map["store_enabled"]
        storeLabel <- map["store_label"]
        documentsEnabled <- map["documents_enabled"]
        documentsLabel <- map["documents_label"]
        resultsEnabled <- map["results_enabled"]
        dashboardEnabled <- map["dashboard_enabled"]
        facebookLoginEnabled <- map["facebook_login_enabled"]
        googleLoginEnabled <- map["google_login_enabled"]
        commentsVotingEnabled <- map["comments_voting_enabled"]
        bookmarksEnabled <- map["bookmarks_enabled"]
        forumEnabled <- map["forum_enabled"]
        twilioEnabled <- map["twilio_enabled"]
        activityFeedEnabled <- map["activity_feed_enabled"]
        enableParallelLoginRestriction <- map["enable_parallel_login_restriction"]
        maxParallelLogins <- map["max_parallel_logins"]
        lockoutLimit <- map["lockout_limit"]
        cooloffTime <- map["cooloff_time"]
        appToolbarLogo <- map["app_toolbar_logo"]
        customRegistrationEnabled <- map["custom_registration_enabled"]
        fairplayCertificateUrl <- map["fairplay_certificate_url"]
        isHelpdeskEnabled <- map["is_helpdesk_enabled"]
        sentryDSN <- map["ios_sentry_dns"]
        disableForgotPassword <- map["disable_forgot_password"]
        enableCustomTest <- map["enable_custom_test"]
        AllowScreenShotInApp <- map["allow_screenshot_in_app"]
        salesforceSdkEnabled <- map["salesforce_sdk_enabled"]
        salesforceMcApplicationId <- map["salesforce_mc_application_id"]
        salesforceMcAccessToken <- map["salesforce_mc_access_token"]
        salesforceFcmSenderId <- map["salesforce_fcm_sender_id"]
        salesforceMarketingCloudUrl <- map["salesforce_marketing_cloud_url"]
        salesforceMid <- map["salesforce_mid"]
    }
    
    override public static func primaryKey() -> String? {
        return "baseUrl"
    }
    
    public static func isAvailable() -> Bool {
        return !DBManager<InstituteSettings>().isEmpty()
    }
}
