//
//  BaseWebViewController.swift
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

open class BaseWebViewController: BaseUIViewController {

    public var webView: WKWebView!
    public var parentView: UIView!
    public var activityIndicator: UIActivityIndicatorView!
    public var webViewDelegate: WKWebViewDelegate!
    public var shouldOpenLinksWithinWebview = false
    public var shouldReload = false
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        parentView = getParentView()
        initWebView()
        webView.navigationDelegate = self
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        parentView.addSubview(webView)
        activityIndicator = UIUtils.initActivityIndicator(parentView: parentView)
        activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y - 50)
    }
    
    open func getParentView() -> UIView {
        return view
    }
    
    open func initWebView() {
        webView = WKWebView(frame: parentView.bounds)
    }

    open func getJavascript() -> String {
        return ""
    }
    
    open func evaluateJavaScript(_ javascript: String) {
        webView.evaluateJavaScript(javascript) {
            (result, error) in
            if error != nil {
                debugPrint(error ?? "No Error Message")
            }
        }
    }

}

extension BaseWebViewController: WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        activityIndicator.startAnimating()

        if (self.shouldReload) {
            webView.reload()
            self.shouldReload = false
        }
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        evaluateJavaScript(getJavascript())
        if webViewDelegate != nil {
            webViewDelegate.onFinishLoadingWebView()
        }
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if !shouldOpenLinksWithinWebview && navigationAction.navigationType == .linkActivated,
            let url = navigationAction.request.url, UIApplication.shared.canOpenURL(url) {
            
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                } else {
                    // openURL(_:) is deprecated in iOS 10+.
                    UIApplication.shared.openURL(url)
                }
                decisionHandler(.cancel)
                return
        } else if (navigationAction.navigationType == .backForward) {
            self.shouldReload = true
        }
        decisionHandler(.allow)
    }

}

public protocol WKWebViewDelegate {
    func onFinishLoadingWebView()
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
