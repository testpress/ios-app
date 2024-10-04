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
import CourseKit

class WebViewUtils {
    
    static func getTestEngineHeader() -> String {
        return "<script src='TestEngine.js'></script>"
    }
    
    static func getQuestionReviewPageHeader() -> String {
        return "<script src='QuestionReviewPage.js'></script>"
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
    
    public static func getBookmarkHeader() -> String {
        return "<link rel='stylesheet' type='text/css' href='bookmark/bookmark.css' />"
            + "<script src='bookmark/Bookmark.js'></script>"
    }
    
    public static func getBookmarkOptionsHeader() -> String {
        return "<link rel='stylesheet' type='text/css' href='bookmark/bookmark_detail.css' />"
            + "<script src='bookmark/BookmarkDetail.js'></script>"
    }
    
    public static func getHeader() -> String {
        var header = "<!DOCTYPE html><meta name='viewport' content='width=device-width, "
            + "initial-scale=1, maximum-scale=1, user-scalable=no' />"
        header += "<link rel='stylesheet' type='text/css' href='typebase.css' />"
        header += "<link rel='stylesheet' type='text/css' href='progress_loader.css' />"
        header += "<link rel='stylesheet' type='text/css' href='dotted_loader.css' />"
        header += "<link rel='stylesheet' type='text/css' href='comments.css' />"
        header += "<link rel='stylesheet' type='text/css' href='post.css' />"
        header += "<link rel='stylesheet' type='text/css' href='icomoon/style.css' />"
        header += "<script src='comments.js'></script>"
        header += "<script src='pseudo_element_selector.js'></script>"
        header += "<script type='text/x-mathjax-config'>" +
            "    MathJax.Hub.Config({" +
            "      messageStyle: 'none'," +
            "      tex2jax: {" +
            "        inlineMath: [['\\\\[','\\\\]'], ['\\\\(','\\\\)']]," +
            "        displayMath: [ ['$$','$$'] ]," +
            "        processEscapes: true" +
            "      }" +
            "    });" +
            "</script>" +
            "<script src='MathJax-2.7.1/MathJax.js?noContrib'></script>" +
            "<script type='text/x-mathjax-config'>" +
            "    MathJax.Ajax.config.path['MathJax'] = 'MathJax-2.7.1';" +
            "    MathJax.Ajax.config.path['Contrib'] = 'MathJax-2.7.1/contrib';" +
            "</script>" +
            "<script src='MathJax-2.7.1/config/TeX-MML-AM_CHTML-full.js'></script>" +
            "<script src='MathJax-2.7.1/extensions/TeX/mhchem3/mhchem.js'></script>"
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
    
    public static func getOptionWithTags(optionText: String, index: Int, color: String?, isCorrect:Bool = false) -> String {
        var html = "\n<div class='review-option-item'>"
        if color == nil {
            html += "<div class='alphabetical-option-ring-general'>"
        } else {
            html += "<div class='alphabetical-option-ring-attempted' style='background-color:" +
                color! + "'>"
        }
        html += "\(Character(UnicodeScalar(65 + index)!))</div>"
        if (isCorrect) {
            html += "<div class='is-correct'>" + optionText + "</div>"
        } else {
            html += "<div>" + optionText + "</div>"
        }
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
    
    public static func getShortAnswerHeadersWithTags() -> String {
        return "" +
            "<tr>" +
            "   <th class='short_answer_option_item table-without-border'>Answers</th>" +
            "   <th class='short_answer_option_item table-without-border'>Marks</th>" +
            "</tr>"
    }
    
    public static func getShortAnswersWithTags(shortAnswerText: String,
                                               marksAllocated: String) -> String {
        return "" +
            "<tr>" +
            "   <td class='short_answer_option_item table-without-border'>" +
                shortAnswerText + "</td>" +
            "   <td class='short_answer_option_item table-without-border'>" +
                marksAllocated + "%</td>" +
            "</tr>";
    }
    
    public static func getFormattedTitle(title: String,
                                         withBookmarkButton: Bool = false,
                                         withBookmarkedState: Bool = false) -> String {
        
        var html = "<div class='title'>" + title + "</div>"
        if withBookmarkButton {
            html += "<div class='bookmark-button-container'>"
            html += WebViewUtils.getBookmarkButtonWithTags(bookmarked: withBookmarkedState,
                                                           alignCenter: true)
            html += "</div>"
        }
        return html + "<hr class='title_separator'>"
    }
    
    public static func getFormattedDiscussionTitle(post: Post) -> String {
        let timeIconData = Images.TimeIcon.image.pngData()
        let encodedTimeIcon = timeIconData?.base64EncodedString()
        let viewsIconData = Images.ViewsIcon.image.pngData()
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
    
    public static func getMoveBookmarkTags() -> String {
        var html = "<div class='bookmark_options_layout' >"
        html += "<div class='bookmark-button' onclick='onClickMoveBookmarkButton()'" +
            "       style='width:121px;'>" +
            "   <img class='bookmark-image' src='images/move_bookmark.svg' />" +
            "   <div class='move-bookmark-text'>Move bookmark</div>" +
            getDottedLoader(marginBottom: 3) +
        "</div>"
        html += "<div class='bookmark-button' onclick='onClickRemoveBookmarkButton()'>" +
            "   <img class='bookmark-image' src='images/remove_bookmark.svg' />" +
            "   <div class='bookmark-text'>Remove</div>" +
            getDottedLoader(marginBottom: 3) +
        "</div>"
        html += "</div>"
        return html
    }
    
    public static func getMoveBookmarkTagsWithPadding() -> String {
        return "<div style='padding: 5px 5px 0px 5px;'>" + getMoveBookmarkTags() + "</div>"
    }
    
    public static func getBookmarkButtonWithTags(bookmarked: Bool,
                                                 alignCenter: Bool = false) -> String {
        let image = bookmarked ? "images/remove_bookmark.svg" : "images/bookmark.svg";
        let text = bookmarked ? "Remove Bookmark" : "Bookmark this";
        let buttonClass = alignCenter ? "bookmark-centered-button" : "bookmark-button"
        return "<div class='" + buttonClass + "' onclick='onClickBookmarkButton()'>" +
            "   <img class='bookmark-image' src='" + image + "' />" +
            "   <span class='bookmark-text'>" + text + "</span>" +
            getDottedLoader() +
        "</div>";
    }
    
    public static func getDottedLoader(marginBottom: Int = 5) -> String {
        return "<div class='lds-ellipsis' style='display:none; margin-bottom:\(marginBottom)px;'>" +
            "   <div></div><div></div><div></div><div></div>" +
            "</div>"
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
    
    public static func addWaterMark(imageUrl: String) -> String {
         return "addWatermark('\(imageUrl)');"
    }
}
