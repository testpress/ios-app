//
//  WebViewUtils.swift
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

import UIKit

class WebViewUtils {
    
    static func getTestEngineHeader() -> String {
        return "<script src='TestEngine.js'></script>"
    }
    
    static func getQuestionListHeader() -> String {
        return "<script src='QuestionListHandler.js'></script>"
    }
    
    static func getRadioButtonInitializer(selectedOption: Int) -> String {
        return "initRadioGroup(\(selectedOption));"
    }
    
    static func getCheckBoxInitializer(selectedOptions: [Int]) -> String {
        return "initCheckBoxGroup(\(selectedOptions));"
    }
    
    public static func getQuestionHeader() -> String {
        return getHeader()
            + "<link rel='stylesheet' type='text/css' href='questions_typebase.css' />"
    }
    
    public static func getHeader() -> String {
        var header = "<!DOCTYPE html><meta name='viewport' content='width=device-width, "
            + "initial-scale=1, maximum-scale=1, user-scalable=no' />"
        header += "<link rel='stylesheet' type='text/css' href='typebase.css' />"
        header += "<link rel='stylesheet' type='text/css' href='progress_loader.css' />"
        header += "<link rel='stylesheet' type='text/css' href='comments.css' />"
        header += "<link rel='stylesheet' type='text/css' href='post.css' />"
        header += "<link rel='stylesheet' type='text/css' href='icomoon/style.css' />"
        header += "<script src='comments.js'></script>"
        header += "<link rel='stylesheet' href='katex/katex.min.css' />"
        header += "<script src='katex/katex.min.js'></script>"
        header += "<script src='katex/contrib/auto-render.min.js'></script>"
        return header
    }
    
    public static func getRadioButtonOptionWithTags(optionText: String, id: Int) -> String {
        var html = "<tr>"
        html += "   <td id='\(id)' onclick='onRadioOptionClick(this)' class='option-item " +
                            "table-without-border'>"
        html += "       <div name='\(id)' class='radio-button-unchecked'></div>"
        html += "       <div>\(optionText)</div>"
        html += "   </td>"
        html += "</tr>"
        return html
    }
    
    public static func getCheckBoxOptionWithTags(optionText: String, id: Int) -> String {
        var html = "<tr>"
        html += "   <td id='\(id)' onclick='onCheckBoxOptionClick(this)' class='option-item " +
                            "table-without-border'>"
        html += "       <div name='\(id)' class='checkbox-unchecked'></div>"
        html += "       <div>\(optionText)</div>"
        html += "   </td>"
        html += "</tr>"
        return html
        
    }
    
    public static func getOptionWithTags(optionText: String, index: Int, color: String?) -> String {
        var html = "\n<div class='review-option-item'>"
        if color == nil {
            html += "<div class='alphabetical-option-ring-general'>"
        } else {
            html += "<div class='alphabetical-option-ring-attempted' style='background-color:" +
                color! + "'>"
        }
        html += "\(Character(UnicodeScalar(65 + index)!))</div>"
        html += "<div>" + optionText + "</div>"
        html += "</div>"
        return html
    }
    
    public static func getCorrectAnswerIndexWithTags(index: Int) -> String {
        return "\n<div class='alphabetical-option-ring-general'>" +
                "\(Character(UnicodeScalar(65 + index)!))</div>"
    }
    
    public static func getReviewHeadingTags(headingText: String) -> String {
        return "<div class='review-heading'>" + headingText + "</div>"
    }
    
    public static func getFormattedTitle(title: String) -> String {
        return "<div class='title'>" + title + "</div><hr class='title_separator'>"
    }
    
    public static func getFormattedDiscussionTitle(post: Post) -> String {
        let timeIconData = UIImagePNGRepresentation(Images.TimeIcon.image)
        let encodedTimeIcon = timeIconData?.base64EncodedString()
        let viewsIconData = UIImagePNGRepresentation(Images.ViewsIcon.image)
        let encodedViewsIcon = viewsIconData?.base64EncodedString()
        var html = "<div class='discussion_title'>" + post.title + "</div>"
        
        html += "<div class='author_layout'>"
        html += "   <img src='\(post.createdBy.mediumImage!)' class='avatar'/>"
        html += "   <div class='author_name_layout'>"
        html += "       <div class='author_name'>" +
                            post.createdBy.displayName +
                        "</div>"
        
        html += "       <div class='post_details'>" +
                            "<img class='time_icon' " +
                                "src='data:image/png;base64,\(encodedTimeIcon!)'/> " +
                            "<div class='post_details_text' >" +
                                FormatDate.getElapsedTime(dateString: post.publishedDate) +
                            "</div>" +
                            "<img class='views_icon' " +
                                "src='data:image/png;base64,\(encodedViewsIcon!)'/> " +
                            "<div class='post_details_text' >\(post.viewsCount!) views</div>" +
                        "</div>"
        
        html += "   </div>" +
                "</div>"
        
        html += "<hr>"
        return html
    }
    
    public static func getHtmlContentWithMargin(_ content: String) -> String {
        return "<div class='html_content'>" + content + "</div>"
    }
    
    public static func getLoadingProgressBar(className: String, visible: Bool = true) -> String {
        let visibility = visible ? "block" : "none"
        var html = "<div class='loading_layout' id='" + className + "'" +
            "style='display:" + visibility + ";'>"
        
        html += "<div id='floatingBarsG'>"
        html += "<div class='blockG' id='rotateG_01'></div>"
        html += "<div class='blockG' id='rotateG_02'></div>"
        html += "<div class='blockG' id='rotateG_03'></div>"
        html += "<div class='blockG' id='rotateG_04'></div>"
        html += "<div class='blockG' id='rotateG_05'></div>"
        html += "<div class='blockG' id='rotateG_06'></div>"
        html += "<div class='blockG' id='rotateG_07'></div>"
        html += "<div class='blockG' id='rotateG_08'></div></div>"
        html += "<div class='loading_text'>Loading...</div>"
        return html + "</div>"
    }

    public static func getCommentHeadingTags(headingText: String) -> String {
        return "<div class='comment_heading'>" + headingText + "</div>"
    }
    
    public static func getCommentItemTags(_ comment: Comment,
                                          seperatorAtTop: Bool = false) -> String {
        
        var html = "<div class='comment_item'><img src='" + comment.user.mediumImage! + "' class='avatar'>"
        html += "<div class='comment_detail_layout'><div style='display:inline-block;'>"
        html += "<div class='username'>" + comment.user.displayName + "</div>·"
        html += "<div class='commentted_time'>" +
                    FormatDate.getElapsedTime(dateString: comment.created) +
                "</div></div>"
        html += "<div class='comment_content'>" + comment.comment + "</div></div></div>"
        if seperatorAtTop {
            html = "<hr>" + html
        } else {
            html += "<hr>"
        }
        return html
    }
    
    public static func formatHtmlToAppendInJavascript(_ html: String) -> String {
        var html = html
        html = html.replacingOccurrences(of: "\\", with: "\\\\")
        html = html.replacingOccurrences(of: "\"", with: "\\\"")
        html = html.replacingOccurrences(of: "\n", with: "\\n")
        return html.replacingOccurrences(of: "\r", with: "")
    }
    
    public static func appendImageTag(imageUrl: String) -> String {
        return "<img src='" + imageUrl + "'/>"
    }
    
}
