//
//  DiscussionThreadDetailViewController.swift
//  ios-app
//
//  Created by Karthik on 29/11/21.
//  Copyright © 2021 Testpress. All rights reserved.
//

import UIKit
import CourseKit

class DiscussionThreadDetailViewController: PostDetailViewController {
    
    override func getFormattedContent(_ post: Post?) -> String {
        var html = WebViewUtils.getHeader() + getTitle() +
            WebViewUtils.getHtmlContentWithMargin(post?.contentHtml ?? "")
        
        if (post?.acceptedAnswer != nil) {
            html += "<hr style='margin-top:20px;'>"
            html += WebViewUtils.getCommentHeadingTags(headingText: "Accepted Answer");
            html += WebViewUtils.getCommentItemTags(post!.acceptedAnswer!.comment)
        } else {
            html += "<hr style='margin-top:20px;'>"
        }
        
        html += WebViewUtils.getCommentHeadingTags(headingText: Strings.COMMENTS);
        
        html += "<div id='empty_comments_description' style='display:none;'>" +
                    "Be the first to post a comment</div>"
        
        html += WebViewUtils.getLoadingProgressBar(className: "preview_comments_loading_layout")
        html += "<div class='load_more_comments_layout' style='display:none;'>" +
                    "<hr>" +
                    "<div class='load_more_comments' onclick='loadMoreComments()'></div>" +
                    "<hr>" +
                "</div>"
        
        html += "<div id='comments_layout'></div>"
        html += WebViewUtils.getLoadingProgressBar(className: "new_comments_loading_layout",
                                                   visible: false)
        
        html += "<div class='load_new_comments_layout' style='display:none;'>" +
                    "<div class='load_new_comments' onclick='loadNewComments()'></div>" +
                "</div>"
        
        return html
    }
}
