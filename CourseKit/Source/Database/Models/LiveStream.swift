//
//  LiveStream.swift
//  ios-app
//
//  Created by Testpress on 20/05/24.
//  Copyright © 2024 Testpress. All rights reserved.
//

import ObjectMapper
import Foundation

public class LiveStream: DBModel {
    @objc dynamic public var title: String = ""
    @objc dynamic public var streamURL: String = ""
    @objc dynamic public var duration: Int = -1
    @objc dynamic public var showRecordedVideo: Bool = false
    @objc dynamic public var status: String = ""
    @objc dynamic public var chatEmbedURL: String = ""

    override static public func primaryKey() -> String? {
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
    
    public var isEnded: Bool {
        return status == "Completed"
    }
    
    public var isRunning: Bool {
        return status == "Running"
    }
    
    public var isNotStarted: Bool {
        return status == "Not Started"
    }

}
