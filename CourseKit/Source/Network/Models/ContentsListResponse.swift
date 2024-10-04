//
//  ContentsListResponse.swift
//  ios-app
//
//  Created by Karthik on 09/05/20.
//  Copyright © 2020 Testpress. All rights reserved.
//

import ObjectMapper
import CourseKit

public class ContentsListResponse {
    public var contents: [Content] = []
    public var attachements: [Attachment] = []
    public var videos: [Video] = []
    public var notes: [HtmlContent] = []
    public var streams: [Stream] = []
    public var exams: [Exam] = []
    public var videoConferences: [VideoConference] = []
    public var liveStreams: [LiveStream] = []
    
    public required init?(map: Map) {
        mapping(map: map)
    }
}

extension ContentsListResponse: TestpressModel {
    public func mapping(map: Map) {
        contents <- map["contents"]
        attachements <- map["attachments"]
        videos <- map["videos"]
        notes <- map["notes"]
        streams <- map["streams"]
        exams <- map["exams"]
        videoConferences <- map["video_conferences"]
        liveStreams <- map["live_streams"]
    }
}
