//
//  QuizReviewViewController.swift
//  ios-app
//
//  Created by Karthik on 19/05/20.
//  Copyright © 2020 Testpress. All rights reserved.
//

import UIKit
import WebKit


class QuizReviewViewController: BaseWebViewController, WKWebViewDelegate, WKScriptMessageHandler {
    var attemptItem: AttemptItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webViewDelegate = self

        webView.loadHTMLString(
              WebViewUtils.getQuestionHeader() + getHtml(),
              baseURL: Bundle.main.bundleURL
          )
    }
    
    override func initWebView() {
        let contentController = WKUserContentController()
        contentController.add(self, name: "callbackHandler")
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        config.preferences.javaScriptEnabled = true
        webView = WKWebView( frame: self.view.bounds, configuration: config)
    }
    
    func onFinishLoadingWebView() {
        
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
    }
    
    func getHtml() -> String {
        let attemptQuestion: AttemptQuestion = attemptItem.question!;
        var html: String = "<div style='padding-left: 5px; padding-right: 5px;'>"
        html += "<div style='overflow:scroll'>"
        html += "<div class='review-question-index'>\(attemptItem.index)</div>"
        
        if (attemptQuestion.direction != nil && !(attemptQuestion.direction!.isEmpty)) {
            html += "<div class='question' style='padding-bottom: 0px;'>" +
                        attemptQuestion.direction! +
                    "</div>";
        }
        
        // Add question
        html += "<div class='question'>" + attemptQuestion.questionHtml! + "</div>";
        var correctAnswerHtml: String = ""
        for (i, attemptAnswer) in attemptQuestion.answers.enumerated() {
            if attemptQuestion.type == "R" || attemptQuestion.type == "C" {
                   var optionColor: String?
                if attemptItem.selectedAnswers.contains(attemptAnswer.id) {
                    if attemptAnswer.isCorrect {
                        optionColor = Colors.MATERIAL_GREEN;
                    } else {
                        optionColor = Colors.MATERIAL_RED
                    }
                }
                   html += "\n" + WebViewUtils.getOptionWithTags(
                       optionText: attemptAnswer.textHtml,
                       index: i,
                       color: optionColor
                   )
                   if attemptAnswer.isCorrect {
                       correctAnswerHtml += WebViewUtils.getCorrectAnswerIndexWithTags(index: i)
                   }
            } else if attemptQuestion.type == "N" {
                   correctAnswerHtml = attemptAnswer.textHtml
               } else {
                   if i == 0 {
                       html += "<table width='100%' style='margin-top:0px; margin-bottom:15px;'>"
                           + WebViewUtils.getShortAnswerHeadersWithTags()
                   }
                   html += WebViewUtils.getShortAnswersWithTags(
                       shortAnswerText: attemptAnswer.textHtml,
                       marksAllocated: attemptAnswer.marks!
                   )
                   if i == attemptQuestion.answers.count - 1 {
                       html += "</table>"
                   }
               }
           }
        
        if attemptQuestion.type == "R" || attemptQuestion.type == "C" || attemptQuestion.type == "N" {
            // Add correct answer
            html += "<div style='display:block;'>" +
                WebViewUtils.getReviewHeadingTags(headingText: Strings.CORRECT_ANSWER) +
                correctAnswerHtml +
            "</div>"
        }
        
        
        // Add explanation
        let explanationHtml = attemptQuestion.explanationHtml
        if (explanationHtml != nil && !explanationHtml!.isEmpty) {
            html += WebViewUtils.getReviewHeadingTags(headingText: Strings.EXPLANATION)
            html += "<div class='review-explanation'>" +
                explanationHtml! +
            "</div>";
        }
        // Add Subject
        if !attemptQuestion.subject.isEmpty &&
            !attemptQuestion.subject.elementsEqual("Uncategorized") {
                html += WebViewUtils.getReviewHeadingTags(headingText: Strings.SUBJECT_HEADING)
                html += "<div class='subject'>" +
                    attemptQuestion.subject +
                "</div>";
        }
       html += "</div>"
       html = html.replacingOccurrences(of: "Â", with: "")

        
        return html
    }
}
