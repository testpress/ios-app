//
//  VideoConference.swift
//  ios-app
//
//  Created by Karthik on 15/09/20.
//  Copyright © 2020 Testpress. All rights reserved.
//

import ObjectMapper
import Realm
import RealmSwift

class VideoConference: DBModel {
    @objc dynamic var id: Int = -1
    @objc dynamic var accessToken: String = ""
    @objc dynamic var duration: Int = -1
    @objc dynamic var conferenceId: String = ""
    @objc dynamic var joinUrl: String = ""
    @objc dynamic var password: String = ""
    @objc dynamic var provider: String = ""
    @objc dynamic var start: String = ""
    @objc dynamic var title: String = ""
    
    public override func mapping(map: Map) {
        joinUrl <- map["join_url"]
        id <- map["id"]
        accessToken <- map["access_token"]
        duration <- map["duration"]
        conferenceId <- map["conference_id"]
        password <- map["password"]
        provider <- map["provider"]
        start <- map["start"]
        title <- map["title"]
    }
    
    override public static func primaryKey() -> String? {
        return "id"
    }
}
