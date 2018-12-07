//
//  Institute.swift
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

class Institute_Settings: DBModel {
    
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
    
    public override func mapping(map: Map) {
        baseUrl <- map["baseUrl"]
        verificationMethod <- map["verificationMethod"]
        allowSignup <- map["allowSignup"]
        forceStudentData <- map["forceStudentData"]
        removeTpBranding <- map["removeTpBranding"]
        url <- map["url"]
        showGameFrontend <- map["showGameFrontend"]
        coursesEnabled <- map["coursesEnabled"]
        coursesEnableGamification <- map["coursesEnableGamification"]
        coursesLabel <- map["coursesLabel"]
        postsEnabled <- map["postsEnabled"]
        postsLabel <- map["postsLabel"]
        storeEnabled <- map["storeEnabled"]
        storeLabel <- map["storeLabel"]
        documentsEnabled <- map["documentsEnabled"]
        documentsLabel <- map["documentsLabel"]
        resultsEnabled <- map["resultsEnabled"]
        dashboardEnabled <- map["dashboardEnabled"]
        facebookLoginEnabled <- map["facebookLoginEnabled"]
        googleLoginEnabled <- map["googleLoginEnabled"]
        commentsVotingEnabled <- map["commentsVotingEnabled"]
        bookmarksEnabled <- map["bookmarksEnabled"]
        forumEnabled <- map["forumEnabled"]
    }
    
    override public static func primaryKey() -> String? {
        return "baseUrl"
    }
    
    public static func isAvailable() {
        let institute = DBManager<Institute_Settings>().getItemsFromDB();
        print("Lol Em Here");
        print(institute);
    }
}
