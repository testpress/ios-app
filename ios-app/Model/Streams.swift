//
//  Streams.swift
//  ios-app
//
//  Created by Karthik raja on 12/11/19.
//  Copyright © 2019 Testpress. All rights reserved.
//

import ObjectMapper

class Stream: DBModel {
    @objc dynamic var url: String = ""
    @objc dynamic var id: Int = -1
    @objc dynamic var format: String = ""
    @objc dynamic var videoId: Int = -1
    
    public override func mapping(map: Map) {
        url <- map["url"]
        id <- map["id"]
        format <- map["format"]
        videoId <- map["video_id"]
    }
    
    override public static func primaryKey() -> String? {
        return "id"
    }
}
