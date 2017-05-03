//
//  QuestionsViewController.swift
//  ios-app
//
//  Copyright © 2017 Testpress. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import WebKit

class QuestionsViewController: BaseQuestionsViewController, WKScriptMessageHandler {
    
    @IBOutlet weak var indexView: UILabel!
    @IBOutlet weak var reviewSwitch: UISwitch!
    
    private var selectedOptions: [Int] = []
    
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
        
        // Set initial values of current selected answer & review
        selectedOptions = attemptItem!.selectedAnswers
        reviewSwitch.isOn = attemptItem!.review!
        attemptItem?.savedAnswers = attemptItem!.selectedAnswers
        attemptItem?.currentReview = attemptItem!.review
        
        indexView!.text = String("\((attemptItem?.index)! + 1)")
        webView.loadHTMLString(WebViewUtils.getHeader() + WebViewUtils.getTestEngineHeader() +
            getQuestionHtml(), baseURL: Bundle.main.bundleURL)
    }

    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        if (message.name == "callbackHandler") {
            let body = message.body
            if let dict = body as? Dictionary<String, AnyObject> {
                let checked = dict["checked"] as! Bool
                let radioOption = dict["radioOption"] as! Bool
                let id = Int(dict["clickedOptionId"] as! String)!
                if (checked) {
                    if (radioOption) {
                        selectedOptions = []
                    }
                    selectedOptions.append(id)
                } else {
                    selectedOptions = selectedOptions.filter { $0 != id } ;
                }
                attemptItem?.savedAnswers = selectedOptions;
            }
        }
    }
    
    override func getJavascript() -> String {
        var javascript = super.getJavascript()
        var selectedAnswers: [Int] = (attemptItem?.selectedAnswers)!
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
        // Add options
        htmlContent += "<table width='100%' style='margin-top:0px;'>";
        for attemptAnswer in attemptQuestion.answers {
            if (attemptItem?.question?.type == "R") {
                htmlContent += "\n" + WebViewUtils.getRadioButtonOptionWithTags(
                    optionText: attemptAnswer.textHtml!, id: attemptAnswer.id!);
            } else {
                htmlContent += "\n" + WebViewUtils.getCheckBoxOptionWithTags(
                    optionText: attemptAnswer.textHtml!, id: attemptAnswer.id!);
            }
        }
        htmlContent = htmlContent + "</table></div>";
        return htmlContent
    }
    
    @IBAction func reviewSwitchValueChanged(_ sender: UISwitch) {
        attemptItem?.currentReview = sender.isOn
    }
}
