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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStatusBarColor()
    }
    
    override func initWebView() {
        let contentController = WKUserContentController()
        contentController.add(self, name: "IosInterface")
        contentController.add(self, name: "startCustomTestInQuizMode")
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
            loadAttempts(attemptId as! String, false)
        }
        if message.name == "startCustomTestInQuizMode" {
            self.emptyView.hide()
            self.activityIndicator?.startAnimating()
            let attemptId = message.body
            print(attemptId)
            loadAttempts(attemptId as! String, true)
        }
    }
    
    func loadAttempts(_ attemptId: String, _ quizMode: Bool) {
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
                // If the attempt has 0:00:00 remaining time, it means infinite timing.
                // Since our app doesn't support exams with infinite timing, we set the remaining time to 24 hours.
                if attempt?.remainingTime == "0:00:00" {
                    attempt?.remainingTime = "24:00:00"
                }
                
                if quizMode {
                    self.goToQuizExam(attempt!)
                } else {
                    self.gotoTestEngine(attempt!)
                }
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
    
    func goToQuizExam(_ attempt: Attempt) {
        let storyboard = UIStoryboard(name: Constants.TEST_ENGINE, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier:
            Constants.QUIZ_EXAM_VIEW_CONTROLLER) as! QuizExamViewController
        viewController.attempt = attempt
        present(viewController, animated: true, completion: nil)
    }
    
    override func onFinishLoadingWebView() {
        activityIndicator?.stopAnimating()
    }
            
    
}
