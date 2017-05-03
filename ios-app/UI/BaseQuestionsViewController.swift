//
//  BaseQuestionsViewController.swift
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

class BaseQuestionsViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var topShadowView: UIView!
    @IBOutlet weak var bottomShadowView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    var webView: WKWebView!
    var attemptItem: AttemptItem!
    let topGradient = CAGradientLayer()
    let bottomGradient = CAGradientLayer()
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator = UIUtils.initActivityIndicator(parentView: view)
        activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y - 50)
        
        initWebView()
        webView.navigationDelegate = self
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(webView)
    }
    
    func initWebView() {
        webView = WKWebView(frame: containerView.bounds)
    }
    
    func getJavascript() -> String {
        let fileURL = URL(fileURLWithPath: Bundle.main.path(forResource: "MathJaxRender",
                                                            ofType:"js", inDirectory:"static")!)
        do {
            return try String(contentsOf: fileURL, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            debugPrint(error.localizedDescription)
        }
        return ""
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        activityIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        webView.evaluateJavaScript(getJavascript()) { (result, error) in
            if error != nil {
                debugPrint(error ?? "no error")
            }
        }
        // Bring top & bottom shadow to front
        view.bringSubview(toFront: bottomShadowView)
        view.bringSubview(toFront: topShadowView)
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

}
