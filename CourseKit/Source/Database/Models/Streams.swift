//
//  Streams.swift
//  ios-app
//
//  Created by Karthik raja on 12/11/19.
//  Copyright © 2019 Testpress. All rights reserved.
//

import ObjectMapper
import Foundation

public class Stream: DBModel {
    @objc dynamic public var url: String = ""
    @objc dynamic public var hlsUrl: String = ""
    @objc dynamic public var format: String = ""
    @objc dynamic public var videoId: Int = -1
    
    public override func mapping(map: Map) {
        url <- map["url"]
        hlsUrl <- map["hls_url"]
        id <- map["id"]
        format <- map["format"]
        videoId <- map["video_id"]
    }
    
    override public static func primaryKey() -> String? {
        return "id"
    }
}
