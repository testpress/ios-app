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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y)
        
        // Set initial values of current selected answer & review
        selectedOptions = Array(attemptItem!.selectedAnswers)
        reviewSwitch.isOn = attemptItem!.review
        try! Realm().write {
            attemptItem?.savedAnswers.removeAll()
            attemptItem?.savedAnswers.append(objectsIn: selectedOptions)
            attemptItem?.currentReview = attemptItem!.review
            attemptItem?.currentShortText = attemptItem!.shortText
            attemptItem?.gapFillResponses.forEach { response in
                gapFilledResponse[response.order] = response.answer as AnyObject
            }
        }

        indexView!.text = String("\((attemptItem?.index)! + 1)")
        webView.loadHTMLString(WebViewUtils.getQuestionHeader() + WebViewUtils.getTestEngineHeader()
            + getQuestionHtml(), baseURL: Bundle.main.bundleURL)
    }
    
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        if (message.name == "callbackHandler") {
            let body = message.body
            if let dict = body as? Dictionary<String, AnyObject> {
                if dict["type"] as! String? == "gap_filled_response" {
                    handleGapFillTypeInput(dict)
                } else if dict["type"] as! String? == "file_type" {
                    MediaPicker.shared.showActions(viewController: self, type: .all)
                } else if let checked = dict["checked"] as? Bool {
                    let radioOption = dict["radioOption"] as! Bool
                    let id = Int(dict["clickedOptionId"] as! String)!
                    if checked {
                        if radioOption {
                            selectedOptions = []
                        }
                        selectedOptions.append(id)
                    } else {
                        selectedOptions = selectedOptions.filter { $0 != id }
                    }
                    try! Realm().write {
                        attemptItem.savedAnswers.removeAll()
                        attemptItem.savedAnswers.append(objectsIn: selectedOptions)
                    }
                } else if let shortText = dict["shortText"] as? String {
                    try! Realm().write {
                        attemptItem.currentShortText = shortText.trim()
                    }
                }
            }
        }
    }
    
    func handleGapFillTypeInput(_ gapFillData: [String : AnyObject]) {
        let order = gapFillData["order"] as! NSString
        gapFilledResponse[order.integerValue] = gapFillData["answer"]
        attemptItem.setGapFillResponses(gapFilledResponse)
    }
    
    override func getJavascript() -> String {
        var javascript = super.getJavascript()
        var selectedAnswers: [Int] = Array((attemptItem?.selectedAnswers)!)
        if !selectedAnswers.isEmpty {
            let optionType: String = (attemptItem?.question?.type)!
            if optionType == "R" {
                javascript +=
                    WebViewUtils.getRadioButtonInitializer(selectedOption: selectedAnswers[0])
            } else {
                javascript += WebViewUtils.getCheckBoxInitializer(selectedOptions: selectedAnswers)
            }
        }
        return javascript
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
    
    func updateGapFillInputElement(element: Element, value: String?) throws {
        try element.attr("oninput", "onFillInTheBlankValueChange(this)")
        try element.addClass("gap_box")
        if value != nil {
            try element.val(value!)
        }
    }
    
    func getQuestionHtml() -> String {
        let attemptQuestion: AttemptQuestion = (attemptItem?.question)!;
        var htmlContent: String = "" +
        "<div style='padding-left: 10px; padding-right: 10px;'>";
        
        // Add direction if present
        if (attemptQuestion.direction != nil &&
            !(attemptQuestion.direction!.isEmpty)) {
            
            htmlContent += "" +
                "<div class='question' style='padding-bottom: 0px;'>" +
                attemptQuestion.direction! +
            "</div>";
        }
        
        // Add question
        htmlContent += "" +
            "<div class='question' style='padding-bottom: 0px;'>" +
            attemptQuestion.questionHtml! +
        "</div>";
        
        if attemptQuestion.type == "R" || attemptQuestion.type == "C" {
            // Add options
            htmlContent += "<table width='100%' style='margin-top:0px;'>"
            
            for attemptAnswer in attemptQuestion.answers {
                if (attemptItem?.question?.type == "R") {
                    htmlContent += "\n" + WebViewUtils.getRadioButtonOptionWithTags(
                        optionText: attemptAnswer.textHtml, id: attemptAnswer.id)
                } else {
                    htmlContent += "\n" + WebViewUtils.getCheckBoxOptionWithTags(
                        optionText: attemptAnswer.textHtml, id: attemptAnswer.id)
                }
            }
            htmlContent += "</table>"
        } else if (attemptQuestion.type == "G") {
            htmlContent = getGapFilledQuestionHtml(htmlContent)
        } else if (attemptQuestion.isFileType) {
            htmlContent += "<button onclick='triggerFileUpload()'> Upload Files </button>"
            
        } else {
            let inputType = attemptQuestion.type == "N" ? "number" : "text"
            let value =
                attemptItem.currentShortText != nil ? attemptItem.currentShortText! : ""
            
            htmlContent += "<input class='edit_box' type='\(inputType)' value='\(value)' " +
                "onpaste='return false' oninput='onValueChange(this)' " +
                "placeholder='YOUR ANSWER'>"
        }
        return htmlContent + "</div>";
    }
    
    @IBAction func reviewSwitchValueChanged(_ sender: UISwitch) {
        try! Realm().write {
            attemptItem?.currentReview = sender.isOn
        }
    }
}
