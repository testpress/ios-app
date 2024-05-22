//
//  LiveStream.swift
//  ios-app
//
//  Created by Testpress on 20/05/24.
//  Copyright © 2024 Testpress. All rights reserved.
//

import ObjectMapper
import Realm
import RealmSwift

class LiveStream: DBModel {
    @objc dynamic var title: String = ""
    @objc dynamic var streamURL: String = ""
    @objc dynamic var duration: Int = -1
    @objc dynamic var showRecordedVideo: Bool = false
    @objc dynamic var status: String = ""
    @objc dynamic var chatEmbedURL: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }
    
    public override func mapping(map: ObjectMapper.Map) {
        title <- map["title"]
        id <- map["id"]
        streamURL <- map["stream_url"]
        duration <- map["duration"]
        showRecordedVideo <- map["show_recorded_video"]
        status <- map["status"]
        chatEmbedURL <- map["chat_embed_url"]
    }
}
