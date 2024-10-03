//
//  Content.swift
//  ios-app
//
//  Copyright © 2017 Testpress. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import ObjectMapper
import RealmSwift
import Foundation

public class Content: DBModel {
    
    @objc dynamic public var index: Int = -1
    @objc dynamic public var url: String = ""
    @objc dynamic public var name: String = ""
    @objc dynamic public var contentDescription: String?
    @objc dynamic public var image: String = ""
    @objc dynamic public var modified: String = ""
    @objc dynamic public var chapterUrl: String = ""
    @objc dynamic public var attemptsUrl: String = ""
    @objc dynamic public var chapterSlug: String = ""
    @objc dynamic public var chapterId: Int = -1
    @objc dynamic public var attemptsCount: Int = 0
    @objc dynamic public var exam: Exam?
    @objc dynamic public var examId: Int = -1
    @objc dynamic public var htmlContentId: Int = -1
    @objc dynamic public var htmlObject: HtmlContent?
    @objc dynamic public var htmlContentTitle: String?
    @objc dynamic public var htmlContentUrl: String!
    @objc dynamic public var order: Int = 0
    @objc dynamic public var hasStarted: Bool = false
    @objc dynamic public var isLocked: Bool = false
    @objc dynamic public var video: Video?
    @objc dynamic public var videoId: Int = -1
    @objc dynamic public var attachment: Attachment?
    @objc dynamic public var attachmentId: Int = -1
    @objc dynamic public var videoConference: VideoConference?
    @objc dynamic public var videoConferenceId: Int = -1
    @objc dynamic public var liveStream: LiveStream?
    @objc dynamic public var liveStreamId: Int = -1
    @objc dynamic public var active: Bool = true
    public var bookmarkId = RealmProperty<Int?>()
    @objc dynamic public var isScheduled: Bool = false
    @objc dynamic public var start: String = ""
    @objc dynamic public var end: String = ""
    @objc dynamic public var contentType: String = ""
    @objc dynamic public var coverImage: String!
    @objc dynamic public var coverImageSmall: String!
    @objc dynamic public var coverImageMedium: String!
    @objc dynamic public var hasEnded: Bool = false

    
    public override func mapping(map: ObjectMapper.Map) {
        url <- map["url"]
        id <- map["id"]
        name <- map["title"]
        contentDescription <- map["description"]
        image <- map["image"]
        modified <- map["modified"]
        chapterUrl <- map["chapter_url"]
        attemptsUrl <- map["attempts_url"]
        chapterSlug <- map["chapter_slug"]
        chapterId <- (map["chapter_id"], transform)
        attemptsCount <- map["attempts_count"]
        exam <- map["exam"]
        examId <- (map["exam_id"], transform)
        htmlContentId <- (map["html_id"], transform)
        htmlContentTitle <- map["html_content_title"]
        htmlContentUrl <- map["html_content_url"]
        order <- map["order"]
        hasStarted <- map["has_started"]
        isLocked <- map["is_locked"]
        video <- map["video"]
        videoId <- (map["video_id"], transform)
        attachment <- map["attachment"]
        attachmentId <- (map["attachment_id"], transform)
        videoConference <- map["video_conference"]
        videoConferenceId <- (map["video_conference_id"], transform)
        liveStream <- map["live_stream"]
        liveStreamId <- (map["live_stream_id"], transform)
        active <- map["active"]
        bookmarkId <- map["bookmark_id"]
        isScheduled <- map["is_scheduled"]
        start <- map["start"]
        contentType <- map["content_type"]
        coverImage <- map["cover_image"]
        coverImageSmall <- map["cover_image_small"]
        coverImageMedium <- map["cover_image_medium"]
        hasEnded <- map["has_ended"]
        end <- map["end"]
    }
    
    override public static func primaryKey() -> String? {
        return "id"
    }
}

let transform = TransformOf<Int, Int>(fromJSON: { (value: Int?) -> Int? in
    return Int(value ?? -1)
}, toJSON: { (value: Int?) -> Int? in
    return Int(value ?? -1)
})

public enum ContentTypeEnum: String {
    case Exam = "Exam"
    case Quiz = "Quiz"
    case Notes = "Notes"
    case Attachment = "Attachment"
    case Html = "Html"
    case Video = "Video"
    case Unknown = "Unknown"
    case VideoConference = "VideoConference"
    case LiveStream = "Live Stream"
}
