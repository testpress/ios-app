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
                
                // Attempt we are receiving here does not contain remaining time because its
                // infinite timing exam attempt. As our app doesn't support exams with infinite
                // timing, so we are set 24 hours for remainingTime in this attempt.
                attempt?.remainingTime = "24:00:00"
                
                self.gotoTestEngine(attempt!)
            })
            
    }
    
    func gotoTestEngine(_ attempt : Attempt) {
        let storyboard = UIStoryboard(name: Constants.TEST_ENGINE, bundle: nil)
        let slideMenuController = storyboard.instantiateViewController(withIdentifier:
            Constants.TEST_ENGINE_NAVIGATION_CONTROLLER) as! UINavigationController
        let viewController =
            slideMenuController.viewControllers.first as! TestEngineSlidingViewController
        viewController.attempt = attempt
        present(slideMenuController, animated: true, completion: nil)
    }
    
    override func onFinishLoadingWebView() {
        activityIndicator?.stopAnimating()
    }
            
    
}
