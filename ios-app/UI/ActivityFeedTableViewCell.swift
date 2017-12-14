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

class ActivityFeedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var activity: UILabel!
    
    var parentViewController: ActivityFeedTableViewController! = nil
    var activityFeed: ActivityFeed!
    var content: Content!
    var post: Post!
    var targetName: String = ""
    
    func initCell(activityFeed: ActivityFeed, viewController: ActivityFeedTableViewController) {
        parentViewController = viewController
        self.activityFeed = activityFeed
        timestamp.text = FormatDate.getElapsedTime(dateString: activityFeed.timestamp)
        var actorName: String = activityFeed.actor.displayName
        var action: String = ""
        var actionObjectName: String = ""
        let target = activityFeed.target as! [String: Any]
        let actionObject = activityFeed.actionObject as! [String: Any]
        targetName = target["name"] as! String
        switch target["model_name"] as! String {
        case "Chapter":
            if activityFeed.verb == "attempted" {
                actorName = "You "
                switch actionObject["model_name"] as! String {
                case "ChapterContentAttempt":
                    switch actionObject["type"] as! String {
                    case "assessment":
                        action = "attempted exam "
                        if let attempt = actionObject["assessment"] as? [String: Any] {
                            if let exam = attempt["exam"] as? [String: Any] {
                                actionObjectName = exam["title"] as! String
                            }
                        }
                        thumbnailImage.image = Images.ExamAttemptedIcon.image
                        break
                    case "article":
                        action = "read the article "
                        if let content = actionObject["content"] as? [String: Any] {
                            if let textContent = content["text_content"] as? [String: Any] {
                                actionObjectName = textContent["title"] as! String
                            }
                        }
                        thumbnailImage.image = Images.PostAdded.image
                        break
                    case "video":
                        action = "watched the video "
                        if let video = actionObject["video"] as? [String: Any] {
                            if let videoContent = video["video_content"] as? [String: Any] {
                                actionObjectName = videoContent["title"] as! String
                            }
                        }
                        thumbnailImage.image = Images.VideoAddedIcon.image
                        break
                    case "attachment":
                        action = "viewed the file "
                        if let attachment = actionObject["attachment"] as? [String: Any] {
                            if let fileContent = attachment["file_content"] as? [String: Any] {
                                actionObjectName = fileContent["title"] as! String
                            }
                        }
                        thumbnailImage.image = Images.FileDownloadIcon.image
                        break
                    default:
                        break
                    }
                    break
                default:
                    break
                }
            } else {
                action = " added "
                switch actionObject["model_name"] as! String {
                case "ChapterContent":
                    let map = Map(mappingType: .fromJSON, JSON: actionObject, toObject: true)
                    content = Content(map: map)
                    content.mapping(map: map)
                    content.order = 0
                    post = nil
                    let id = actionObject["id"] as! Int
                    content.url = Constants.BASE_URL + "api/v2.3/contents/\(id)/"
                    if let exam = actionObject["exam"] as? [String: Any] {
                        action += "an exam "
                        actionObjectName = exam["title"] as! String
                        thumbnailImage.image = Images.ExamAddedIcon.image
                        content.exam?.attemptsUrl = content.exam!.url! + "attempts/"
                    } else if let htmlTitle = actionObject["html_content_title"] as? String {
                        action += "an ariticle "
                        actionObjectName = htmlTitle
                        thumbnailImage.image = Images.PostAdded.image
                        content.htmlContentUrl = content.url + "html/"
                    } else if let video = actionObject["video"] as? [String: Any] {
                        action += "a video "
                        actionObjectName = video["title"] as! String
                        thumbnailImage.image = Images.VideoAddedIcon.image
                    } else if let attachment = actionObject["attachment"] as? [String: Any] {
                        action += "a file "
                        actionObjectName = attachment["title"] as! String
                        thumbnailImage.image = Images.FileDownloadIcon.image
                    }
                default:
                    break
                }
            }
            break
        case "PostCategory":
            action = " added an article "
            actionObjectName = actionObject["title"] as! String
            thumbnailImage.image = Images.PostAdded.image
            let map = Map(mappingType: .fromJSON, JSON: actionObject, toObject: true)
            post = Post(map: map)
            post.mapping(map: map)
            post.url = Constants.BASE_URL + "api/v2.2/posts/" + post.slug
            post.commentsUrl = Constants.BASE_URL + "api/v2.2/posts/\(post.id!)/comments/"
            break
        default:
            break
        }
        activity.text = actorName + action + actionObjectName + " in " + targetName
        let tapRecognizer = UITapGestureRecognizer(target: self,
                                                   action: #selector(self.onItemClick))
        
        addGestureRecognizer(tapRecognizer)
    }
    
    @objc func onItemClick() {
        if post != nil {
            let storyboard = UIStoryboard(name: Constants.POST_STORYBOARD, bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier:
                Constants.POST_DETAIL_VIEW_CONTROLLER) as! PostDetailViewController
            
            viewController.post = post
            parentViewController.present(viewController, animated: true, completion: nil)
        } else {
            let storyboard = UIStoryboard(name: Constants.CHAPTER_CONTENT_STORYBOARD, bundle: nil)
            let viewController = storyboard.instantiateViewController(
                withIdentifier: Constants.CONTENT_DETAIL_PAGE_VIEW_CONTROLLER)
                as! ContentDetailPageViewController
            
            viewController.contents = [content]
            viewController.title = targetName
            viewController.position = 0
            parentViewController.present(viewController, animated: true, completion: nil)
        }
    }
    
}
