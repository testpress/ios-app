//
//  AccountDeletionConfirmationViewController.swift
//  ios-app
//
//  Created by Testpress on 26/04/24.
//  Copyright © 2024 Testpress. All rights reserved.
//

import Foundation
import WebKit

class ConfirmDeletionViewController: WebViewController, WKScriptMessageHandler {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStatusBarColor()
    }
    
    override func initWebView() {
        let contentController = WKUserContentController()
        contentController.add(self, name: "onAccountDeletionSuccess")
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        config.preferences.javaScriptEnabled = true
        webView = WKWebView(frame: parentView.bounds, configuration: config)
        webView.customUserAgent = "TestpressiOSApp/WebView"
    }
    
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if (message.name == "onAccountDeletionSuccess") {
            self.emptyView.hide()
            self.activityIndicator?.startAnimating()
            UIUtils.logout()
            showLoginActivity()
        }
    }
    
    func showLoginActivity() {
        let storyboard = UIStoryboard(name: Constants.MAIN_STORYBOARD, bundle: nil)
        let loginActivityViewController = storyboard.instantiateViewController(
            withIdentifier: Constants.LOGIN_ACTIVITY_VIEW_CONTROLLER)
        
        self.present(loginActivityViewController, animated: true, completion: nil)
    }


    override func onFinishLoadingWebView() {
        activityIndicator?.stopAnimating()
    }

    override func goBack() {
        self.cleanAllCookies()
        self.dismiss(animated: true, completion: nil)
    }
}
