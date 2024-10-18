//
//  ActivityFeedTableViewCell.swift
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
import UIKit
import CourseKit

class ActivityFeedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var activity: UILabel!
    @IBOutlet weak var examDetails: UIView!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var studentsAttemptedCount: UILabel!
    @IBOutlet weak var questionsCount: UILabel!
    
    var parentViewController: ActivityFeedTableViewController! = nil
    var activityFeed: ActivityFeed!
    var content: Content!
    var post: Post!
    var targetName: String = ""
    var actionObjectName: String = ""
    
    func initCell(activityFeed: ActivityFeed, viewController: ActivityFeedTableViewController) {
        parentViewController = viewController
        self.activityFeed = activityFeed
        let pager = viewController.pager
        let exams = pager.exams
        timestamp.text = FormatDate.getElapsedTime(dateString: activityFeed.timestamp)
        var actorName: String = activityFeed.actor.displayName.capitalized
        var action: String = ""
        examDetails.isHidden = true
        if activityFeed.verb == "attempted" {
            actorName = "You "
            if let contentAttempt = activityFeed.actionObject as? ContentAttempt {
                if let content = pager.contents[contentAttempt.chapterContentId] {
                    content.order = 0
                    content.url = TestpressCourse.shared.baseURL + "/api/v2.2/contents/\(content.id)/"
                    content.attemptsUrl = content.url + "attempts/"
                    self.content = content
                    if contentAttempt.assessment != nil {
                        action = "attempted exam "
                        actionObjectName = exams[contentAttempt.assessment.exam]!.title
                        thumbnailImage.image = Images.ExamAttemptedIcon.image
                    } else if contentAttempt.content != nil {
                        action = "read the article "
                        actionObjectName = contentAttempt.content.title
                        thumbnailImage.image = Images.PostAdded.image
                    } else if contentAttempt.video != nil {
                        action = "watched the video "
                        actionObjectName = contentAttempt.video.videoContent.title
                        thumbnailImage.image = Images.VideoAddedIcon.image
                    } else if contentAttempt.attachment != nil {
                        action = "viewed the file "
                        actionObjectName = contentAttempt.attachment.title
                        thumbnailImage.image = Images.FileDownloadIcon.image
                    }
                }
                let chapter = activityFeed.target as! Chapter
                targetName = chapter.name
            }
        } else {
            if let content = activityFeed.actionObject as? Content {
                action = " added "
                content.order = 0
                content.url = TestpressCourse.shared.baseURL + "/api/v2.2/contents/\(content.id)/"
                content.attemptsUrl = content.url + "attempts/"
                if content.examId != -1 {
                    action += "an exam "
                    let exam = exams[content.examId]!
                    content.exam = exam
                    actionObjectName = exam.title
                    thumbnailImage.image = Images.ExamAddedIcon.image
                    duration.text = exam.duration
                    studentsAttemptedCount.text = "\(exam.studentsAttemptedCount) students"
                    questionsCount.text = String(exam.numberOfQuestions)
                    examDetails.isHidden = false
                } else if content.htmlContentId != -1 {
                    action += "an ariticle "
                    let htmlContent = pager.htmlContents[content.htmlContentId]!
                    content.htmlContentTitle = htmlContent.title
                    content.htmlContentUrl = content.url + "html/"
                    actionObjectName = htmlContent.title
                    thumbnailImage.image = Images.PostAdded.image
                    content.htmlContentUrl = content.url + "html/"
                } else if content.videoId != -1 {
                    action += "a video "
                    let video = pager.videos[content.videoId]!
                    content.video = video
                    actionObjectName = video.title
                    thumbnailImage.image = Images.VideoAddedIcon.image
                } else if content.attachmentId != -1 {
                    action += "a file "
                    let attachment = pager.attachments[content.attachmentId]!
                    content.attachment = attachment
                    actionObjectName = attachment.title
                    thumbnailImage.image = Images.FileDownloadIcon.image
                }
                self.content = content
                let chapter = activityFeed.target as! Chapter
                targetName = chapter.name
            } else if let post = activityFeed.actionObject as? Post {
                content = nil
                action = " added an article "
                actionObjectName = post.title
                thumbnailImage.image = Images.PostAdded.image
                post.url = TestpressCourse.shared.baseURL + "/api/v2.2/posts/" + post.slug
                post.commentsUrl = TestpressCourse.shared.baseURL + "/api/v2.2/posts/\(post.id!)/comments/"
                self.post = post
                if let category = activityFeed.target as? CourseKit.Category {
                    targetName = category.name
                } else {
                    targetName = ""
                }
            }
        }
        var text = actorName + action
        let actionObjectNameStartIndex = text.count
        text += actionObjectName
        var targetNameStartIndex: Int!
        if !targetName.isEmpty {
            text += " in "
            targetNameStartIndex = text.count
            text += targetName
        }
        activity.text = text
        let attributedString = NSMutableAttributedString(string: text)
        var range = NSRange(location: 0, length: actorName.count)
        setRubikMedium(in: attributedString, forRange: range)
        
        range = NSRange(location: actionObjectNameStartIndex, length: actionObjectName.count)
        setRubikMedium(in: attributedString, forRange: range)
        
        if !targetName.isEmpty {
            range = NSRange(location: targetNameStartIndex, length: targetName.count)
            setRubikMedium(in: attributedString, forRange: range)
        }
        
        activity.attributedText = attributedString
        
        let tapRecognizer = UITapGestureRecognizer(target: self,
                                                   action: #selector(self.onItemClick))
        
        addGestureRecognizer(tapRecognizer)
    }
    
    func setRubikMedium(in attributedString: NSMutableAttributedString, forRange: NSRange) {
        attributedString.addAttribute(
            NSAttributedString.Key.font,
            value: UIFont(name: "lato-bold", size: 14.0)!,
            range: forRange
        )
    }
    
    @objc func onItemClick() {
        if content != nil {
            let storyboard = UIStoryboard(name:Constants.CHAPTER_CONTENT_STORYBOARD, bundle: TestpressCourse.bundle)
            let viewController = storyboard.instantiateViewController(
                withIdentifier: Constants.CONTENT_DETAIL_PAGE_VIEW_CONTROLLER)
                as! ContentDetailPageViewController
            
            viewController.contents = [content]
            viewController.title = targetName.isEmpty ? actionObjectName : targetName
            viewController.position = 0
            parentViewController.present(viewController, animated: true, completion: nil)
        } else {
            let storyboard = UIStoryboard(name: Constants.POST_STORYBOARD, bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier:
                Constants.POST_DETAIL_VIEW_CONTROLLER) as! PostDetailViewController
            
            viewController.post = post
            parentViewController.present(viewController, animated: true, completion: nil)
        }
    }
    
}
