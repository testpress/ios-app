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
            WebViewUtils.getQuestionHeader() + WebViewUtils.getTestEngineHeader() + getHtml(),
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
    
    
    func getHtml() -> String {
        let question = attemptItem.question!;
        var html: String = "<div style='padding-left: 5px; padding-right: 5px;'>"
        html += "<div style='overflow:scroll'>"
        html += "<div class='review-question-index'>\(attemptItem.index)</div>"
        html += getDirectionHTML(question: question)
        html += getQuestionHTML(question: question)
        html += getAnswerHTML()
        html += getExplanationHTML(question: question)
        html += getSubjectHTML(question: question)
        html += "</div>"
        html = html.replacingOccurrences(of: "Â", with: "")        
        return html
    }
    
    func getDirectionHTML(question: AttemptQuestion) -> String {
        var htmlContent = ""
        if !question.direction.isNilOrEmpty {
            htmlContent += "<div class='question' style='padding-bottom: 0px;'>" +
                question.direction! +
            "</div>";
        }
        return htmlContent
    }
    
    
    func getQuestionHTML(question: AttemptQuestion) -> String {
        return "<div class='question'>" + question.questionHtml! + "</div>";
    }
    
    func getExplanationHTML(question: AttemptQuestion) -> String {
        var htmlContent = ""
        let explanationHtml = question.explanationHtml
        if !explanationHtml.isNilOrEmpty {
            htmlContent += WebViewUtils.getReviewHeadingTags(headingText: Strings.EXPLANATION)
            htmlContent += "<div class='review-explanation'>" +
                explanationHtml! +
            "</div>";
        }
        return htmlContent
    }
    
    func getSubjectHTML(question: AttemptQuestion) -> String {
        var htmlContent = ""
        if !question.subject.isEmpty &&
            !question.subject.elementsEqual("Uncategorized") {
            htmlContent += WebViewUtils.getReviewHeadingTags(headingText:Strings.SUBJECT_HEADING)
            htmlContent += "<div class='subject'>" +
                question.subject +
            "</div>";
        }
        return htmlContent
    }
    
    func getAnswerHTML() -> String {
        var html = ""
        let question = attemptItem.question!;
        
        var correctAnswerHtml: String = ""
        for (i, attemptAnswer) in question.answers.enumerated() {
            if question.isSingleMcq || question.isMultipleMcq {
                var optionColor: String?
                if attemptItem.selectedAnswers.contains(attemptAnswer.id) {
                    if attemptAnswer.isCorrect {
                        optionColor = Colors.MATERIAL_GREEN
                    } else {
                        optionColor = Colors.MATERIAL_RED
                    }
                }
                
                if attemptAnswer.isCorrect {
                    optionColor = Colors.MATERIAL_GREEN
                }
                
                html += "\n" + WebViewUtils.getOptionWithTags(
                    optionText: attemptAnswer.textHtml,
                    index: i,
                    color: optionColor,
                    isCorrect: attemptAnswer.isCorrect
                )
                
                if attemptAnswer.isCorrect {
                    correctAnswerHtml += WebViewUtils.getCorrectAnswerIndexWithTags(index: i)
                }
                
            } else if question.isNumerical {
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
                if i == question.answers.count - 1 {
                    html += "</table>"
                }
            }
        }
        
        if question.questionType == .SINGLE_CORRECT_MCQ || question.questionType == .MULTIPLE_CORRECT_MCQ || question.questionType == .NUMERICAL {
            html += "<div style='display:block;'>" +
                WebViewUtils.getReviewHeadingTags(headingText: Strings.CORRECT_ANSWER) +
                correctAnswerHtml +
            "</div>"
        }
        
        return html
    }
    
    override func getJavascript() -> String {
        let instituteSettings = DBManager<InstituteSettings>().getResultsFromDB()[0]
        var javascript = super.getJavascript()
        javascript += WebViewUtils.addWaterMark(imageUrl: instituteSettings.appToolbarLogo)
        return javascript
    }
    
    func onFinishLoadingWebView() {
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    }
}
