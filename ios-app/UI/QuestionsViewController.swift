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

class QuestionsViewController: UIViewController, WKScriptMessageHandler, WKUIDelegate,
    WKNavigationDelegate {
    
    @IBOutlet weak var indexView: UILabel!
    @IBOutlet weak var topShadowView: UIView!
    @IBOutlet weak var bottomShadowView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var reviewSwitch: UISwitch!
    
    var webView: WKWebView!
    var attemptItem: AttemptItem?
    private var selectedOptions: [Int] = []
    let topGradient = CAGradientLayer()
    let bottomGradient = CAGradientLayer()
    var activityIndicator: UIActivityIndicatorView?
    
    override func loadView() {
        super.loadView()
        
        selectedOptions = attemptItem!.selectedAnswers
       
        activityIndicator = UIUtils.initActivityIndicator(parentView: self.view)
        activityIndicator?.center = CGPoint(x: view.center.x, y: view.center.y - 50)
        
        let contentController = WKUserContentController()
        contentController.add(self, name: "callbackHandler")
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        config.preferences.javaScriptEnabled = true
        
        webView = WKWebView( frame: self.containerView!.bounds, configuration: config)
        webView.navigationDelegate = self
        webView.autoresizingMask =  [.flexibleWidth, .flexibleHeight]
        
        self.containerView.addSubview(self.webView)
        
        reviewSwitch.isOn = attemptItem!.review!

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set initial values of current selected answer & review
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
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        activityIndicator?.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator?.stopAnimating()
        let fileURL = URL(fileURLWithPath: Bundle.main.path(forResource: "MathJaxRender",
                                                            ofType:"js", inDirectory:"static")!)
        do {
            var javascript = try String(contentsOf: fileURL, encoding: String.Encoding.utf8)
            var selectedAnswers: [Int] = (attemptItem?.selectedAnswers)!;
            if !selectedAnswers.isEmpty {
                let optionType: String = (attemptItem?.question?.type)!;
                if optionType == "R" {
                    javascript += WebViewUtils.getRadioButtonInitializer(
                        selectedOption: selectedAnswers[0]);
                } else {
                    javascript += WebViewUtils.getCheckBoxInitializer(
                        selectedOptions: selectedAnswers);
                }
            }
            webView.evaluateJavaScript(javascript) { (result, error) in
                if error != nil {
                    debugPrint(error ?? "no error")
                }
            }
            // Bring top & bottom shadow to front
            view.bringSubview(toFront: bottomShadowView)
            view.bringSubview(toFront: topShadowView)
        } catch let error as NSError {
            debugPrint(error.localizedDescription)
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
    
    override func viewDidLayoutSubviews() {
        // Add gradient shadow layer to the shadow container view
        topGradient.frame = topShadowView.bounds
        topGradient.colors = [UIColor.black.cgColor, UIColor.white.cgColor]
        topShadowView.layer.insertSublayer(topGradient, at: 0)
        
        bottomGradient.frame = bottomShadowView.bounds
        bottomGradient.colors = [UIColor.white.cgColor, UIColor.black.cgColor]
        bottomShadowView.layer.insertSublayer(bottomGradient, at: 0)
    }
    
    @IBAction func reviewSwitchValueChanged(_ sender: UISwitch) {
        attemptItem?.currentReview = sender.isOn
    }
}
