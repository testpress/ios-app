//
//  MindsetReflectionViewController.swift
//  CourseKit
//

import UIKit
import WebKit

class MindsetReflectionViewController: WebViewController, WKScriptMessageHandler {

    var onReflectionSubmitted: (() -> Void)?
    var onReflectionSkipped: (() -> Void)?
    var submissionMandatory: Bool = false
    
    override func viewDidLoad() {
        self.useSSOLogin = true
        self.displayNavbar = true
        self.title = "Mindset Reflection"
        super.viewDidLoad()
        
        if submissionMandatory {
            self.backButton.isHidden = true
            self.navItem?.leftBarButtonItem = nil
            self.navItem?.hidesBackButton = true
        }
    }
    
    override func initWebView() {
        let contentController = WKUserContentController()
        contentController.add(self, name: "onReflectionSubmitted")
        contentController.add(self, name: "onReflectionSkipped")
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        config.preferences.javaScriptEnabled = true
        
        webView = WKWebView(frame: parentView.bounds, configuration: config)
        webView.customUserAgent = "TestpressiOSApp/WebView"
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "onReflectionSubmitted" {
            self.cleanAllCookies()
            self.dismiss(animated: true) {
                self.onReflectionSubmitted?()
            }
        } else if message.name == "onReflectionSkipped" {
            self.cleanAllCookies()
            self.dismiss(animated: true) {
                self.onReflectionSkipped?()
            }
        }
    }
}
