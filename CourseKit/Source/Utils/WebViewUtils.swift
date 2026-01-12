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

public class WebViewUtils {
    
    public static func getTestEngineHeader() -> String {
        return "<script src='\(getStaticFileUrl(for: "TestEngine", withExtension: "js")!)'></script>"
    }
    
    public static func getQuestionReviewPageHeader() -> String {
        return "<script src='\(getStaticFileUrl(for: "QuestionReviewPage", withExtension: "js")!)'></script>"
    }
    
    public static func getQuestionListHeader() -> String {
        return "<script src='\(getStaticFileUrl(for: "QuestionListHandler", withExtension: "js")!)'></script>"
    }
    
    public static func getRadioButtonInitializer(selectedOption: Int) -> String {
        return "initRadioGroup(\(selectedOption));"
    }
    public static func getCheckBoxInitializer(selectedOptions: [Int]) -> String {
        return "initCheckBoxGroup(\(selectedOptions));"
    }
    
    public static func getQuestionHeader() -> String {
        return getHeader()
            + "<link rel='stylesheet' type='text/css' href='\(getStaticFileUrl(for: "questions_typebase", withExtension: "css")!)' />"
    }
    
    public static func getBookmarkHeader(inject: Bool = false) -> String {
        if inject {
            var html = ""
            if let css = getStaticFileContent(for: "bookmark/bookmark", withExtension: "css") {
                html += "<style>\(css)</style>"
            }
            if let js = getStaticFileContent(for: "bookmark/Bookmark", withExtension: "js") {
                html += "<script>\(js)</script>"
            }
            return html
        }
        return "<link rel='stylesheet' type='text/css' href='\(getStaticFileUrl(for: "bookmark/bookmark", withExtension: "css")!)' />"
            + "<script src='\(getStaticFileUrl(for: "bookmark/Bookmark", withExtension: "js")!)'></script>"
    }
    
    public static func getBookmarkOptionsHeader() -> String {
        return "<link rel='stylesheet' type='text/css' href='\(getStaticFileUrl(for: "bookmark/bookmark_detail", withExtension: "css")!)' />"
            + "<script src='\(getStaticFileUrl(for: "bookmark/BookmarkDetail", withExtension: "js")!)'></script>"
    }
    
    public static func getHeader(injectCSS: Bool = false) -> String {
        var header = "<!DOCTYPE html><meta name='viewport' content='width=device-width, "
            + "initial-scale=1, maximum-scale=1, user-scalable=no' />"

        let cssFiles = ["typebase", "progress_loader", "dotted_loader", "comments", "post", "icomoon/style"]
        
        if injectCSS {
            for file in cssFiles {
                if let cssContent = getStaticFileContent(for: file, withExtension: "css") {
                    header += "<style>\(cssContent)</style>"
                }
            }
        } else {
            for file in cssFiles {
                header += "<link rel='stylesheet' type='text/css' href='\(getStaticFileUrl(for: file, withExtension: "css")!)' />"
            }
        }
        
        header += "<script src='\(getStaticFileUrl(for: "comments", withExtension: "js")!)'></script>"
        header += "<script src='\(getStaticFileUrl(for: "pseudo_element_selector", withExtension: "js")!)'></script>"
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
            "<script src='\(getStaticFileUrl(for: "MathJax-2.7.1/MathJax", withExtension: "js")!)'></script>" +
            "<script type='text/x-mathjax-config'>" +
        "    MathJax.Ajax.config.path['MathJax'] = \(getStaticFileUrl(for: "MathJax-2.7.1", withExtension: nil)!)';" +
        "    MathJax.Ajax.config.path['Contrib'] = \(getStaticFileUrl(for: "MathJax-2.7.1/contrib", withExtension: nil)!)';" +
            "</script>" +
            "<script src='\(getStaticFileUrl(for: "MathJax-2.7.1/config/TeX-MML-AM_CHTML-full", withExtension: "js")!)'></script>" +
            "<script src='\(getStaticFileUrl(for: "MathJax-2.7.1/extensions/TeX/mhchem3/mhchem", withExtension: "js")!)'></script>"
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
                                         withBookmarkedState: Bool = false,
                                         useDataURI: Bool = false) -> String {
        
        var html = "<div class='title'><b>" + title + "</b></div>"
        if withBookmarkButton {
            html += "<div class='bookmark-button-container'>"
            html += WebViewUtils.getBookmarkButtonWithTags(bookmarked: withBookmarkedState,
                                                           alignCenter: true,
                                                           useDataURI: useDataURI)
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
        var html = "<div class='bookmark_options_layout'>"

        html += "<div class='bookmark-button' onclick='onClickMoveBookmarkButton()' style='width:121px;'>" +
            "<img class='bookmark-image' src='\(getStaticFileUrl(for: "images/move_bookmark", withExtension: "svg")!)' />" +
            "<div class='move-bookmark-text'>Move bookmark</div>" +
            getDottedLoader(marginBottom: 3) +
        "</div>"
        html += "<div class='bookmark-button' onclick='onClickRemoveBookmarkButton()'>" +
            "<img class='bookmark-image' src='\(getStaticFileUrl(for: "images/remove_bookmark", withExtension: "svg")!)' />" +
            "<div class='bookmark-text'>Remove</div>" +
            getDottedLoader(marginBottom: 3) +
        "</div>"
        
        html += "</div>"
        return html
    }
    
    public static func getMoveBookmarkTagsWithPadding() -> String {
        return "<div style='padding: 5px 5px 0px 5px;'>" + getMoveBookmarkTags() + "</div>"
    }
    
    public static func getBookmarkButtonWithTags(bookmarked: Bool, alignCenter: Bool = false, useDataURI: Bool = false) -> String {
        let imagePath = bookmarked ? "images/remove_bookmark" : "images/bookmark"
        var imageSrc = ""
        
        if useDataURI {
            if let base64 = getStaticFileBase64(for: imagePath, withExtension: "svg") {
                imageSrc = "data:image/svg+xml;base64,\(base64)"
            }
        } else {
            imageSrc = getStaticFileUrl(for: imagePath, withExtension: "svg") ?? ""
        }

        let text = bookmarked ? "Remove Bookmark" : "Bookmark this"
        let buttonClass = alignCenter ? "bookmark-centered-button" : "bookmark-button"

        var html = "<div class='\(buttonClass)' onclick='onClickBookmarkButton()'>"
        html += "   <img class='bookmark-image' src='\(imageSrc)' />"
        html += "   <span class='bookmark-text'>\(text)</span>"
        html += getDottedLoader()
        html += "</div>"
        
        return html
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
    
    public static func getResourcesBasePath() -> String? {
        return TestpressCourse.bundle.resourcePath
    }

    public static func getStaticFileUrl(for filePath: String, withExtension fileExtension: String?) -> String? {
        guard let path = getStaticFilePath(for: filePath, withExtension: fileExtension) else {
            return nil
        }
        return URL(fileURLWithPath: path).absoluteString
    }

    public static func getStaticFileContent(for filePath: String, withExtension fileExtension: String?) -> String? {
        guard let path = getStaticFilePath(for: filePath, withExtension: fileExtension) else {
            return nil
        }
        return try? String(contentsOfFile: path, encoding: .utf8)
    }

    public static func getStaticFileBase64(for filePath: String, withExtension fileExtension: String?) -> String? {
        guard let path = getStaticFilePath(for: filePath, withExtension: fileExtension) else {
            return nil
        }
        let data = try? Data(contentsOf: URL(fileURLWithPath: path))
        return data?.base64EncodedString()
    }

    private static func getStaticFilePath(for filePath: String, withExtension fileExtension: String?) -> String? {
        guard var resourcePath = getResourcesBasePath() else {
            return nil
        }
        
        #if SWIFT_PACKAGE
            resourcePath = (resourcePath as NSString).appendingPathComponent("static")
        #endif

        var fullPath = (resourcePath as NSString).appendingPathComponent(filePath)

        if let fileExtension = fileExtension {
            fullPath = (fullPath as NSString).appendingPathExtension(fileExtension) ?? fullPath
        }

        return fullPath
    }
}
