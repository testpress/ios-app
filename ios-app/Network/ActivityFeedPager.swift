//
//  ActivityFeedPager.swift
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

import Alamofire
import ObjectMapper
import CourseKit

class ActivityFeedPager: BasePager<ActivityFeedResponse, ActivityFeed> {
    
    var contentTypes = [Int: ContentType]()
    var users = [Int: User]()
    var chapters = [Int: Chapter]()
    var contents = [Int: Content]()
    var contentAttempts = [Int: ContentAttempt]()
    var htmlContents = [Int: HtmlContent]()
    var videos = [Int: Video]()
    var attachments = [Int: Attachment]()
    var exams = [Int: Exam]()
    var posts = [Int: Post]()
    var postCategories = [Int: CourseKit.Category]()
    
    override func getItems(_ resultResponse: ActivityFeedResponse) -> [ActivityFeed] {
        let activities: [ActivityFeed] = resultResponse.activities
        if !activities.isEmpty {
            // DON'T CHANGE THE BELOW ORDER
            response!.results.contentTypes.forEach { contentType in
                contentTypes.updateValue(contentType, forKey: contentType.id)
            }
            response!.results.users.forEach { user in
                users.updateValue(user, forKey: user.id!)
            }
            response!.results.chapters.forEach { chapter in
                chapters.updateValue(chapter, forKey: chapter.id)
            }
            response!.results.chapterContentAttempts.forEach { contentAttempt in
                contentAttempts.updateValue(contentAttempt, forKey: contentAttempt.id)
            }
            response!.results.htmlContents.forEach { htmlContent in
                htmlContents.updateValue(htmlContent, forKey: htmlContent.id)
            }
            response!.results.videoContents.forEach { video in
                videos.updateValue(video, forKey: video.id)
            }
            response!.results.attachmentContents.forEach { attachment in
                attachments.updateValue(attachment, forKey: attachment.id)
            }
            response!.results.exams.forEach { exam in
                exams.updateValue(exam, forKey: exam.id)
            }
            response!.results.chapterContents.forEach { content in
                contents.updateValue(content, forKey: content.id)
            }
            response!.results.posts.forEach { post in
                posts.updateValue(post, forKey: post.id)
            }
            response!.results.postCategories.forEach { postCategory in
                postCategories.updateValue(postCategory, forKey: postCategory.id)
            }
        }
        return activities
    }
    
    override func getResponse(page: Int) {
        queryParams.updateValue(Constants.ADMIN, forKey: Constants.FILTER)
        queryParams.updateValue(String(page), forKey: Constants.PAGE)
        TPApiClient.getListItems(
            type: ActivityFeedResponse.self,
            endpointProvider: TPEndpointProvider(.getActivityFeed, queryParams: queryParams),
            completion: responseHandler!
        )
    }
    
    override func register(resource activity: ActivityFeed) -> ActivityFeed? {
        
        activity.actor = users[Int(activity.actorObjectId)!]
        let actionObjectId = Int(activity.actionObjectObjectId)!
        switch contentTypes[activity.actionObjectContentType]!.model {
        case "chapter":
            activity.actionObject = chapters[actionObjectId]
            activity.actionObjectType = String(describing: Chapter.self)
            break
        case "chaptercontent":
            activity.actionObject = contents[actionObjectId]
            activity.actionObjectType = String(describing: Content.self)
            break
        case "chaptercontentattempt":
            activity.actionObject = contentAttempts[actionObjectId]
            activity.actionObjectType = String(describing: ContentAttempt.self)
            break
        case "post":
            activity.actionObject = posts[actionObjectId]
            activity.actionObjectType = String(describing: Post.self)
            break
        default:
            break
        }
        
        if activity.targetObjectId != nil {
            let targetObjectId = Int(activity.targetObjectId)!
            switch contentTypes[activity.targetContentType]!.model {
            case "chapter":
                activity.target = chapters[targetObjectId]
                break
            case "chaptercontent":
                activity.target = contents[targetObjectId]
                break
            case "post":
                activity.target = posts[targetObjectId]
                break
            case "postcategory":
                activity.target = postCategories[targetObjectId]
                break
            default:
                break
            }
        }
        if activity.actor == nil {
            debugPrint("activity.actor not Exists", activity.id)
            return nil
        }
        if activity.actionObject == nil {
            debugPrint("activity.actionObject not Exists", activity.id)
            return nil
        }
        return activity
    }
    
    override func getId(resource: ActivityFeed) -> Int {
        return resource.id
    }
    
}
