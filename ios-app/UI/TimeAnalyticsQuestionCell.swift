//
//  TimeAnalyticsQuestionCell.swift
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
import WebKit
import CourseKit

class TimeAnalyticsQuestionCell: UITableViewCell {
    
    func initCell(attemptItem: AttemptItem,
                  parentViewController: TimeAnalyticsTableViewController) {
        
        let contentController = WKUserContentController()
        contentController.add(parentViewController, name: "callbackHandler")
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        config.preferences.javaScriptEnabled = true
        let webView = WKWebView( frame: contentView.bounds, configuration: config)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = parentViewController
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.tag = attemptItem.index - 1
        contentView.addSubview(webView)
        webView.loadHTMLString(
           WebViewUtils.getQuestionHeader() + getHtml(attemptItem),
            baseURL: Bundle.main.bundleURL
        )
    }
    
    func getHtml(_ attemptItem: AttemptItem) -> String {
        let attemptQuestion: AttemptQuestion = (attemptItem.question)!
        var html: String = "<div style='padding-left: 5px; padding-right: 5px; overflow:scroll'>"
        
        // Add direction/passage if present
        if (attemptQuestion.direction != nil && !(attemptQuestion.direction!.isEmpty)) {
            html += "<div class='question' style='padding-bottom: 0px;'>" +
                attemptQuestion.direction! +
            "</div>";
        }
        
        // Add question
        html += "<div class='question'>" +
            attemptQuestion.questionHtml! +
        "</div>";
        
        var correctAnswerHtml: String = ""
        for (i, attemptAnswer) in attemptQuestion.answers.enumerated() {
            if attemptAnswer.isCorrect {
                correctAnswerHtml += "\n" + WebViewUtils.getOptionWithTags(
                    optionText: attemptAnswer.textHtml,
                    index: i,
                    color: nil
                )
            }
        }
        
        // Add correct answer
        html += "<div style='display:block;'>" +
            WebViewUtils.getReviewHeadingTags(headingText: Strings.CORRECT_ANSWER) +
            correctAnswerHtml +
        "</div>";
        
        // Add explanation
        let explanationHtml = attemptQuestion.explanationHtml
        if (explanationHtml != nil && !explanationHtml!.isEmpty) {
            html += WebViewUtils.getReviewHeadingTags(headingText: Strings.EXPLANATION)
            html += "<div class='review-explanation'>" +
                explanationHtml! +
            "</div>";
        }
        return html + "</div>"
    }
    
}

