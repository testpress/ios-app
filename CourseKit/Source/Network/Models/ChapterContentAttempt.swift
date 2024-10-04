//
//  ChapterContentAttempt.swift
//  ios-app
//
//  Created by Karthik on 29/04/21.
//  Copyright © 2021 Testpress. All rights reserved.
//

import ObjectMapper
import CourseKit

public class ChapterContentAttempt {
    
    public var id: Int?
    public var chapterContentId: Int?
    public var userContentId: Int?
    public var userVideoId: Int?
    public var assessmentId: Int?
    public var userAttachmentId: Int?
    public var userWiziqId: Int?

    public required init?(map: Map) {
    }
}

extension ChapterContentAttempt: TestpressModel {
    public func mapping(map: Map) {
        id <- map["id"]
        chapterContentId <- map["chapter_content_id"]
        userContentId <- map["user_content_id"]
        userVideoId <- map["user_video_id"]
        assessmentId <- map["assessment_id"]
        userAttachmentId <- map["user_attachment_id"]
        userWiziqId <- map["user_wiziq_id"]
    }
}
