//
//  CustomTestGenerationViewController.swift
//  ios-app
//
//  Created by Prithuvi on 03/08/23.
//  Copyright © 2023 Testpress. All rights reserved.
//

import Foundation
import WebKit

class CustomTestGenerationViewController: WebViewController, WKScriptMessageHandler {
    
    override func initWebView() {
        let contentController = WKUserContentController()
        contentController.add(self, name: "IosInterface")
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        config.preferences.javaScriptEnabled = true
        webView = WKWebView(frame: parentView.bounds, configuration: config)
    }
    
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if (message.name == "IosInterface") {
            self.emptyView.hide()
            self.activityIndicator?.startAnimating()
            let attemptId = message.body
            print(attemptId)
            loadAttempts(attemptId as! String)
        }
    }
    
    func loadAttempts(_ attemptId: String) {
        TPApiClient.request(
            type: Attempt.self,
            endpointProvider: TPEndpointProvider(
                .put,
                url: Constants.BASE_URL+"/api/v2.2/attempts/"+attemptId+"/" + TPEndpoint.resumeAttempt.urlPath
            ),
            completion: {
                attempt, error in
                
                if let error = error {
                    self.showErrorMessage(error: error)
                    return
                }
                
                print(attempt?.url)
                print(attempt?.id)
                print(attempt?.date)
            })
            
    }
            
    
}
