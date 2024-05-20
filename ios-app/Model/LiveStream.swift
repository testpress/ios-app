//
//  LiveStream.swift
//  ios-app
//
//  Created by Testpress on 20/05/24.
//  Copyright © 2024 Testpress. All rights reserved.
//

import Foundation
import RealmSwift

class LiveStream: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var title: String = ""
    @objc dynamic var streamURL: String = ""
    @objc dynamic var duration: Int = 0
    @objc dynamic var showRecordedVideo: Bool = false
    @objc dynamic var status: String = ""
    @objc dynamic var chatEmbedURL: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(id: Int, title: String, streamURL: String, duration: Int?, showRecordedVideo: Bool, status: String, chatEmbedURL: String) {
        self.init()
        self.id = id
        self.title = title
        self.streamURL = streamURL
        self.duration = duration ?? 0
        self.showRecordedVideo = showRecordedVideo
        self.status = status
        self.chatEmbedURL = chatEmbedURL
    }
}
