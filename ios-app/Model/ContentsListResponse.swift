//
//  ContentsListResponse.swift
//  ios-app
//
//  Created by Karthik on 09/05/20.
//  Copyright © 2020 Testpress. All rights reserved.
//

import ObjectMapper

public class ContentsListResponse {
    var contents: [Content] = []
    var attachements: [Attachment] = []
    var videos: [Video] = []
    var notes: [HtmlContent] = []
    var streams: [Stream] = []
    var exams: [Exam] = []
    
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
    }
}
