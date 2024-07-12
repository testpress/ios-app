//
//  QuestionsViewController.swift
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
import RealmSwift
import SwiftSoup

class QuestionsViewController: BaseQuestionsViewController, WKScriptMessageHandler {
    
    @IBOutlet weak var indexView: UILabel!
    @IBOutlet weak var reviewSwitch: UISwitch!
    
    private var selectedOptions: [Int] = []
    private var gapFilledResponse: [Int: AnyObject] = [:]
    
    override func initWebView() {
        let contentController = WKUserContentController()
        contentController.add(self, name: "callbackHandler")
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        config.preferences.javaScriptEnabled = true
        
        webView = WKWebView( frame: self.containerView!.bounds, configuration: config)
    }
    
    override func getJavascript() -> String {
        var javascript = super.getJavascript()
        var selectedAnswers: [Int] = Array((attemptItem?.selectedAnswers)!)
        guard let questionType = attemptItem?.question?.type else { return javascript }
        
        if !selectedAnswers.isEmpty {
            javascript += (questionType == "R") ? WebViewUtils.getRadioButtonInitializer(selectedOption: selectedAnswers[0]) : WebViewUtils.getCheckBoxInitializer(selectedOptions: selectedAnswers)
        }
        return javascript
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupActivityIndicator()
        loadAttemptItemData()
        setupWebView()
    }
    
    private func setupActivityIndicator() {
        activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y)
    }
    
    private func loadAttemptItemData() {
        guard let attemptItem = attemptItem else { return }
        
        // Set initial values of current selected answer & review
        selectedOptions = Array(attemptItem.selectedAnswers)
        reviewSwitch.isOn = attemptItem.review
        
        try! Realm().write {
            attemptItem.savedAnswers.removeAll()
            attemptItem.savedAnswers.append(objectsIn: selectedOptions)
            attemptItem.currentReview = attemptItem.review
            attemptItem.currentShortText = attemptItem.shortText
            attemptItem.gapFillResponses.forEach { response in
                gapFilledResponse[response.order] = response.answer as AnyObject
            }
            attemptItem.localEssayText = attemptItem.essayText
        }
        
        indexView.text = String(attemptItem.index + 1)
    }
    
    private func setupWebView() {
        webView.loadHTMLString(
            WebViewUtils.getQuestionHeader() + WebViewUtils.getTestEngineHeader() + getQuestionHtml(),
            baseURL: Bundle.main.bundleURL
        )
    }
    
    func getQuestionHtml() -> String {
        guard let attemptQuestion = attemptItem?.question else { return "" }
        
        var htmlContent = "<div style='padding-left: 10px; padding-right: 10px;'>"
        
        if let direction = attemptQuestion.direction, !direction.isEmpty {
            htmlContent += "<div class='question' style='padding-bottom: 0px;'>\(attemptQuestion.getLanguageBasedDirection(self.language))</div>"
        }
        
        htmlContent += "<div class='question' style='padding-bottom: 0px;'>\(attemptQuestion.getLanguageBasedQuestion(self.language))</div>"
        
        switch attemptQuestion.type {
        case "G":
            htmlContent = getGapFilledQuestionHtml(htmlContent)
        case "R", "C":
            htmlContent += getOptionsHtml(for: attemptQuestion)
        case "E":
            htmlContent += getEssayQuestionInputHtml()
        default:
            htmlContent += getShortAnswerInputHtml(for: attemptQuestion)
        }
        
        return htmlContent + "</div>"
    }
    
    private func getOptionsHtml(for question: AttemptQuestion) -> String {
        var htmlContent = "<table width='100%' style='margin-top:0px;'>"
        
        question.answers.forEach { answer in
            if question.type == "R" {
                htmlContent += WebViewUtils.getRadioButtonOptionWithTags(optionText: answer.getTextHtml(question, self.language), id: answer.id)
            } else {
                htmlContent += WebViewUtils.getCheckBoxOptionWithTags(optionText: answer.getTextHtml(question, self.language), id: answer.id)
            }
        }
        
        return htmlContent + "</table>"
    }
    
    func getEssayQuestionInputHtml() -> String {
        var htmlContent = "<textarea class='essay_topic' oninput='onEssayValueChange(this)' rows='10'>"
        if let essayText = attemptItem?.localEssayText, !essayText.isEmpty {
            htmlContent += essayText
        }
        return htmlContent + "</textarea>"
    }
    
    
    func getGapFilledQuestionHtml(_ htmlContent: String) -> String {
        do {
            let doc = try SwiftSoup.parse(htmlContent)
            let elements = try doc.select("input")
            for (index, element) in elements.enumerated() {
                try updateGapFillInputElement(element: element, value: gapFilledResponse[index + 1] as? String)
            }
            return try doc.html()
        } catch Exception.Error( _, _) {
            return htmlContent
        } catch {
            return htmlContent
        }
    }
    
    private func getShortAnswerInputHtml(for question: AttemptQuestion) -> String {
        let inputType = question.type == "N" ? "number" : "text"
        let value = attemptItem?.currentShortText ?? ""
        return "<input class='edit_box' type='\(inputType)' value='\(value)' onpaste='return false' oninput='onValueChange(this)' placeholder='YOUR ANSWER'>"
    }
    
    func updateGapFillInputElement(element: Element, value: String?) throws {
        try element.attr("oninput", "onFillInTheBlankValueChange(this)")
        try element.addClass("gap_box")
        if let value = value {
            try element.val(value)
        }
    }
    
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "callbackHandler", let dict = message.body as? [String: AnyObject] else { return }

        switch dict["type"] as? String {
        case "gap_filled_response":
            handleGapFillTypeInput(dict)
        case let type where type == "radio_response" || type == "checkbox_response":
            handleOptionSelection(dict)
        case "short_text_response":
            handleShortTextInput(dict)
        case "essay_response":
            handleEssayInput(dict)
        default:
            break
        }
    }
    
    func handleGapFillTypeInput(_ gapFillData: [String: AnyObject]) {
        guard let order = gapFillData["order"] as? NSString else { return }
        
        gapFilledResponse[order.integerValue] = gapFillData["answer"]
        attemptItem?.setGapFillResponses(gapFilledResponse)
    }
    
    private func handleOptionSelection(_ dict: [String: AnyObject]) {
        guard let checked = dict["checked"] as? Bool, let id = Int(dict["clickedOptionId"] as? String ?? ""), let radioOption = dict["radioOption"] as? Bool else { return }
        
        if checked {
            if radioOption { selectedOptions = [] }
            selectedOptions.append(id)
        } else {
            selectedOptions.removeAll { $0 == id }
        }
        
        try! Realm().write {
            attemptItem?.savedAnswers.removeAll()
            attemptItem?.savedAnswers.append(objectsIn: selectedOptions)
        }
    }
    
    private func handleShortTextInput(_ dict: [String: AnyObject]) {
        guard let shortText = dict["shortText"] as? String else { return }
        
        try! Realm().write {
            attemptItem?.currentShortText = shortText.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    private func handleEssayInput(_ dict: [String: AnyObject]) {
        guard let essay = dict["essay"] as? String else { return }
        
        try! Realm().write {
            attemptItem?.localEssayText = essay
        }
    }
    
    @IBAction func reviewSwitchValueChanged(_ sender: UISwitch) {
        try! Realm().write {
            attemptItem?.currentReview = sender.isOn
        }
    }
    
}
