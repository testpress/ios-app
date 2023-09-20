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
import Realm
import RealmSwift

class Content: DBModel {
    
    @objc dynamic var index: Int = -1
    @objc dynamic var url: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var contentDescription: String?
    @objc dynamic var image: String = ""
    @objc dynamic var modified: String = ""
    @objc dynamic var chapterUrl: String = ""
    @objc dynamic var attemptsUrl: String = ""
    @objc dynamic var chapterSlug: String = ""
    @objc dynamic var chapterId: Int = -1
    @objc dynamic var attemptsCount: Int = 0
    @objc dynamic var exam: Exam?
    @objc dynamic var examId: Int = -1
    @objc dynamic var htmlContentId: Int = -1
    @objc dynamic var htmlObject: HtmlContent?
    @objc dynamic var htmlContentTitle: String?
    @objc dynamic var htmlContentUrl: String!
    @objc dynamic var order: Int = 0
    @objc dynamic var hasStarted: Bool = false
    @objc dynamic var isLocked: Bool = false
    @objc dynamic var video: Video?
    @objc dynamic var videoId: Int = -1
    @objc dynamic var attachment: Attachment?
    @objc dynamic var attachmentId: Int = -1
    @objc dynamic var videoConference: VideoConference?
    @objc dynamic var videoConferenceId: Int = -1
    @objc dynamic var active: Bool = true
    var bookmarkId = RealmOptional<Int>()
    @objc dynamic var isScheduled: Bool = false
    @objc dynamic var start: String = ""
    @objc dynamic var end: String = ""
    @objc dynamic var contentType: String = ""
    @objc dynamic var coverImage: String!
    @objc dynamic var coverImageSmall: String!
    @objc dynamic var coverImageMedium: String!
    @objc dynamic var hasEnded: Bool = false

    
    public static func fetchContent(url:String, completion: @escaping(Content?, TPError?) -> Void) {
        TPApiClient.request(
            type: Content.self,
            endpointProvider: TPEndpointProvider(.get, url: url),
            completion: {
                content, error in
                if let error = error {
                    debugPrint(error.message ?? "No error")
                    debugPrint(error.kind)
                } else {
                    let content: Content = content!
                    print("Content : \(content)")
                }
                completion(content, error)
        })
    }
    
    public func getAttemptsUrl() -> String {
        var url = String(format: "%@%@%d/attempts/", Constants.BASE_URL , TPEndpoint.getContents.urlPath, self.id)
        url = url.replacingOccurrences(of: "v2.3", with: "v2.2.1")
        return url
    }
    
    public func getContentType() -> ContentTypeEnum {
        return ContentTypeEnum(rawValue: contentType) ?? .Unknown
    }
    
    public func getUrl() -> String {
        var contentDetailUrl = String(format: "%@/api/v2.4/contents/%d/", Constants.BASE_URL , self.id)
        return url.isEmpty ? contentDetailUrl : url
    }

    
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
}
