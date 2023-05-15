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
import Realm
import RealmSwift

class InstituteSettings: DBModel {
    
    @objc dynamic var name: String = ""
    @objc dynamic var baseUrl: String = ""
    @objc dynamic var verificationMethod: String = ""
    @objc dynamic var allowSignup: Bool = false
    @objc dynamic var forceStudentData: Bool = false
    @objc dynamic var removeTpBranding: Bool = false
    @objc dynamic var showGameFrontend: Bool = false
    @objc dynamic var url: String = ""
    @objc dynamic var coursesEnabled: Bool = false
    @objc dynamic var coursesEnableGamification: Bool = false
    @objc dynamic var coursesLabel: Bool = false
    @objc dynamic var postsEnabled: Bool = false
    @objc dynamic var postsLabel: String = ""
    @objc dynamic var storeEnabled: Bool = false
    @objc dynamic var documentsEnabled: Bool = false
    @objc dynamic var documentsLabel: String = ""
    @objc dynamic var storeLabel: String = ""
    @objc dynamic var resultsEnabled: Bool = false
    @objc dynamic var dashboardEnabled: Bool = false
    @objc dynamic var facebookLoginEnabled: Bool = false
    @objc dynamic var googleLoginEnabled: Bool = false
    @objc dynamic var commentsVotingEnabled: Bool = false
    @objc dynamic var bookmarksEnabled: Bool = false
    @objc dynamic var forumEnabled: Bool = false
    @objc dynamic var twilioEnabled: Bool = false
    @objc dynamic var activityFeedEnabled: Bool = false
    @objc dynamic var enableParallelLoginRestriction: Bool = false
    @objc dynamic var maxParallelLogins: Int = 0
    @objc dynamic var lockoutLimit: String = ""
    @objc dynamic var cooloffTime: String = ""
    @objc dynamic var appToolbarLogo: String = ""
    @objc dynamic var customRegistrationEnabled: Bool = false
    @objc dynamic var fairplayCertificateUrl: String = ""
    @objc dynamic var isHelpdeskEnabled: Bool = false
    @objc dynamic var sentryDSN: String = ""
    @objc dynamic var disableForgotPassword: Bool = false

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
    }
    
    override public static func primaryKey() -> String? {
        return "baseUrl"
    }
    
    public static func isAvailable() -> Bool {
        return !DBManager<InstituteSettings>().isEmpty()
    }
}
