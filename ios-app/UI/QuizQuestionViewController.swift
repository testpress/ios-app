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
    
    
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        var selectedOptions = [Int]()
        if (message.name == "callbackHandler") {
            let body = message.body
            if let dict = body as? Dictionary<String, AnyObject> {
                if let checked = dict["checked"] as? Bool {
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
                    attemptItem = attemptItemRepository.selectAnswer(id: attemptItem.id, selectedOptions: selectedOptions)
                } else if let shortText = dict["shortText"] as? String {
                    attemptItem = attemptItemRepository.selectAnswer(id: attemptItem.id, shortText: shortText.trim())
                }
            }
        }
    }
    
    override func getJavascript() -> String {
        var javascript = super.getJavascript()
        var selectedAnswers: [Int] = Array(attemptItem.selectedAnswers)
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
    
    func getHtml() -> String {
        let attemptQuestion: AttemptQuestion = attemptItem.question!;
        var htmlContent: String = "" +
        "<div style='padding-left: 10px; padding-right: 10px;'>";
        htmlContent += "<div class='review-question-index'>\(attemptItem.index)</div>"

        
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
                if (attemptQuestion.type == "R") {
                    htmlContent += "\n" + WebViewUtils.getRadioButtonOptionWithTags(
                        optionText: attemptAnswer.textHtml, id: attemptAnswer.id)
                    let a = WebViewUtils.getRadioButtonOptionWithTags(
                    optionText: attemptAnswer.textHtml, id: attemptAnswer.id)
                } else {
                    htmlContent += "\n" + WebViewUtils.getCheckBoxOptionWithTags(
                        optionText: attemptAnswer.textHtml, id: attemptAnswer.id)
                }
            }
            htmlContent += "</table>"
        } else {
            let inputType = attemptQuestion.type == "N" ? "number" : "text"
            let value = ""
//                attemptItem.currentShortText != nil ? attemptItem.currentShortText! : ""
            
            htmlContent += "<input class='edit_box' type='\(inputType)' value='\(value)' " +
                "onpaste='return false' oninput='onValueChange(this)' " +
                "placeholder='YOUR ANSWER'>"
        }
        htmlContent = htmlContent + "</div>";
        htmlContent = htmlContent.replacingOccurrences(of: "Â", with: "")
     
//
//        do {
//            htmlContent = Entities.escape(htmlContent)
//            print("Html Content : \(htmlContent)")
//
//            let a = convertSpecialCharacters(string: htmlContent)
//
//            return try Entities.unescape(a)
//        }  catch {
//
//        }
        return htmlContent
    }
    
    
    func onFinishLoadingWebView() {
        
    }
}

func convertSpecialCharacters(string: String) -> String {
        var newString = string
        let char_dictionary = [
            "&amp;" : "&",
            "&lt;" : "<",
            "&gt;" : ">",
            "&quot;" : "\"",
            "&apos;" : "'",
            "&nbsp;": " "
        ];
        for (escaped_char, unescaped_char) in char_dictionary {
            newString = newString.replacingOccurrences(of: escaped_char, with: unescaped_char, options: NSString.CompareOptions.literal, range: nil)
        }
        return newString
}
