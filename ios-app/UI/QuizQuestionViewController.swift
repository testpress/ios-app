//
//  QuizQuestionViewController.swift
//  ios-app
//
//  Created by Karthik on 15/05/20.
//  Copyright © 2020 Testpress. All rights reserved.
//

import Foundation
import WebKit

class QuizQuestionViewController:BaseWebViewController, WKWebViewDelegate, WKScriptMessageHandler {
    var attemptItem: AttemptItem!
    let attemptItemRepository = AttemptItemRepository()
    private var selectedOptions: [Int] = []
    private var viewModel: QuizQuestionsViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = QuizQuestionsViewModel()
        webViewDelegate = self
        webView.loadHTMLString(
            WebViewUtils.getQuestionHeader() + WebViewUtils.getTestEngineHeader() + getHTML(),
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
    
    
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        if (message.name == "callbackHandler") {
            let body = message.body

            if let dict = body as? Dictionary<String, AnyObject> {
                handleUserInputSelection(data: dict)
            }
        }
    }
    
    func handleUserInputSelection(data: Dictionary<String, AnyObject>) {
        if let checked = data["checked"] as? Bool {
            let radioOption = data["radioOption"] as! Bool
            let id = Int(data["clickedOptionId"] as! String)!
            
            if checked {
                if radioOption {
                    selectedOptions = []
                }
                selectedOptions.append(id)
            } else {
                selectedOptions = selectedOptions.filter { $0 != id }
            }
            
            attemptItem = viewModel.selectAnswer(id: attemptItem.id, selectedOptions: selectedOptions)
        } else if let shortText = data["shortText"] as? String {
            attemptItem = viewModel.selectAnswer(id: attemptItem.id, shortText: shortText.trim())
        }
    }
    
    override func getJavascript() -> String {
        var javascript = super.getJavascript()
        let selectedAnswers: [Int] = Array(attemptItem.selectedAnswers)
        if !selectedAnswers.isEmpty {
            let optionType: String = (attemptItem.question?.type)!
            if optionType == "R" {
                javascript +=
                    WebViewUtils.getRadioButtonInitializer(selectedOption: selectedAnswers[0])
            } else {
                javascript += WebViewUtils.getCheckBoxInitializer(selectedOptions: selectedAnswers)
            }
        }
        return javascript
    }
    
    func getHTML() -> String {
        let attemptQuestion: AttemptQuestion = attemptItem.question!;
        var htmlContent = "<div style='padding-left: 10px; padding-right: 10px;'>";
        htmlContent += "<div class='review-question-index'>\(attemptItem.index)</div>"
        htmlContent += getDirectionHTML(question: attemptQuestion)
        htmlContent += getQuestionHTML(question: attemptQuestion)
        htmlContent += getOptionsHTML()
        htmlContent = htmlContent + "</div>";
        htmlContent = htmlContent.replacingOccurrences(of: "Â", with: "")
        return htmlContent
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
        return "<div class='question' style='padding-bottom: 0px;'>" +
            question.questionHtml! +
        "</div>";
    }
    
    func getOptionsHTML() -> String {
        let attemptQuestion: AttemptQuestion = attemptItem.question!
        var htmlContent = ""
        if attemptQuestion.isSingleMcq || attemptQuestion.isMultipleMcq {
            htmlContent += getMCQHTML()
        } else if attemptQuestion.isShortAnswer {
            htmlContent += getShortAnswerHTML()
        }
        return htmlContent
    }
    
    func getMCQHTML() -> String {
        let attemptQuestion = attemptItem.question!
        var htmlContent = "<table width='100%' style='margin-top:0px;'>"
        for attemptAnswer in attemptQuestion.answers {
            if (attemptQuestion.type == "R") {
                htmlContent += "\n" + WebViewUtils.getRadioButtonOptionWithTags(
                    optionText: attemptAnswer.textHtml, id: attemptAnswer.id)
            } else {
                htmlContent += "\n" + WebViewUtils.getCheckBoxOptionWithTags(
                    optionText: attemptAnswer.textHtml, id: attemptAnswer.id)
            }
        }
        htmlContent += "</table>"
        return htmlContent
    }
    
    func getShortAnswerHTML() -> String {
        let attemptQuestion = attemptItem.question!
        var htmlContent = "<table width='100%' style='margin-top:0px;'>"
        let inputType = attemptQuestion.type == "N" ? "number" : "text"
        let value = attemptItem.currentShortText != nil ? attemptItem.currentShortText! : ""
        htmlContent += "<input class='edit_box' type='\(inputType)' value='\(value)' " +
            "onpaste='return false' oninput='onValueChange(this)' " +
            "placeholder='YOUR ANSWER'>"
        return htmlContent
    }
    
    func onFinishLoadingWebView() {
    }
}
