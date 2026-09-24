//
//  VideoConference.swift
//  ios-app
//
//  Created by Karthik on 15/09/20.
//  Copyright © 2020 Testpress. All rights reserved.
//

import ObjectMapper
import Foundation

public class VideoConference: DBModel {
    @objc dynamic public var accessToken: String = ""
    @objc dynamic public var duration: Int = -1
    @objc dynamic public var conferenceId: String = ""
    @objc dynamic public var joinUrl: String = ""
    @objc dynamic public var password: String = ""
    @objc dynamic public var provider: String = ""
    @objc dynamic public var start: String = ""
    @objc dynamic public var title: String = ""
    @objc dynamic public var showRecordedVideo: Bool = false
    @objc dynamic public var state: String = ""
    
    public override func mapping(map: ObjectMapper.Map) {
        joinUrl <- map["join_url"]
        id <- map["id"]
        accessToken <- map["access_token"]
        duration <- map["duration"]
        conferenceId <- map["conference_id"]
        password <- map["password"]
        provider <- map["provider"]
        start <- map["start"]
        title <- map["title"]
        showRecordedVideo <- map["show_recorded_video"]
        state <- map["state"]
    }
    
    public var isEnded: Bool {
        return state == "Ended"
    }
    
    override public static func primaryKey() -> String? {
        return "id"
    }
}
