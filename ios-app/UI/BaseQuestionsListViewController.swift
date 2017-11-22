//
//  BaseQuestionsListViewController.swift
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

protocol QuestionListDelegate {
    func gotoQuestion(index: Int)
}

class BaseQuestionsListViewController: BaseWebViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var buttonLayout: UIView!
    @IBOutlet weak var bottomShadowView: UIView!
    
    var attemptItems = [AttemptItem]()
    var currentPosition: Int!
    var delegate: QuestionListDelegate?
    
    override func initWebView() {
        let contentController = WKUserContentController()
        contentController.add(self, name: "callbackHandler")
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        config.preferences.javaScriptEnabled = true
        
        webView = WKWebView(frame: containerView.bounds, configuration: config)
        webViewDelegate = self
    }
    
    override func getParentView() -> UIView {
        return containerView
    }
    
    func getHtml() -> String {
        var html: String = "<table width='100%' style='margin-top:0px;'>";
        for (index, attemptItem) in attemptItems.enumerated() {
            let attemptQuestion: AttemptQuestion = (attemptItem.question)!
            let selectedBackground: String = currentPosition == index ? "selected-item" : ""
            html += "<tr><td id='\(index)' onclick='onClickQuestionItem(this)' " +
                "class='question-list-item table-without-padding \(selectedBackground)'>\n"
            
            let color = getIndexBorderColor(attemptItem: attemptItem)
            // Add index
            html += "<div><div class='question-list-index' style='border-color: \(color)'>" +
                "\(index + 1)</div></div>\n"
            
            // Add direction(passage) if question html is empty
            if (attemptQuestion.direction != nil && !(attemptQuestion.direction!.isEmpty) &&
                attemptQuestion.questionHtml!.isEmpty) {
                
                html += "<div class='question-list-content' style='padding-bottom: 0px;'>" +
                    attemptQuestion.direction! +
                "</div>\n";
            }
            // Add question
            html += "<div class='question-list-content'>" +
                attemptQuestion.questionHtml! +
            "</div>\n";
            
            html += "</td></tr>"
        }
        return html + "</table>"
    }
    
    func getIndexBorderColor(attemptItem: AttemptItem) -> String {
        return Colors.GRAY_LIGHT_DARK
    }
    
    @IBAction func hideQuestionList(_ sender: UIButton) {
        delegate?.gotoQuestion(index: currentPosition)
    }
    
    // Set frames of the views in this method to support both portrait & landscape view
    override func viewDidLayoutSubviews() {
        // Add gradient shadow layer to the shadow container view
        let bottomGradient = CAGradientLayer()
        bottomGradient.frame = bottomShadowView.bounds
        bottomGradient.colors = [UIColor.white.cgColor, UIColor.black.cgColor]
        bottomShadowView.layer.insertSublayer(bottomGradient, at: 0)
    }
}

extension BaseQuestionsListViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        
        if (message.name == "callbackHandler") {
            if let dict = message.body as? Dictionary<String, String> {
                delegate?.gotoQuestion(index: Int(dict["clickedItemId"]!)!)
            }
        }
    }
}

extension BaseQuestionsListViewController: WKWebViewDelegate {
    
    func onFinishLoadingWebView() {
        webView.evaluateJavaScript(
        "document.getElementById('\(currentPosition!)').scrollIntoView()") {
            (result, error) in
            if error != nil {
                debugPrint(error ?? "No Error Message")
            }
        }
        view.bringSubview(toFront: buttonLayout)
    }
}

extension BaseQuestionsListViewController: QuestionsSlidingMenuDelegate {
    
    func updateQuestions(_ attemptItems: [AttemptItem]) {
        self.attemptItems = attemptItems
    }
    
    func displayQuestions(currentQuestionIndex: Int) {
        currentPosition = currentQuestionIndex
        webView.loadHTMLString(
            WebViewUtils.getQuestionHeader() + WebViewUtils.getQuestionListHeader() + getHtml(),
            baseURL: Bundle.main.bundleURL
        )
    }
}
