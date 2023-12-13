//
//  CustomTestGenerationViewController.swift
//  ios-app
//
//  Created by Prithuvi on 03/08/23.
//  Copyright © 2023 Testpress. All rights reserved.
//

import Foundation
import WebKit

let DEFAULT_EXAM_TIME = "24:00:00"
let INFINITE_EXAM_TIME = "0:00:00"

class CustomTestGenerationViewController: WebViewController, WKScriptMessageHandler {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStatusBarColor()
    }
    
    override func initWebView() {
        let contentController = WKUserContentController()
        contentController.add(self, name: "IosInterface")
        contentController.add(self, name: "startCustomTestInQuizMode")
        contentController.add(self, name: "showReview")
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
        if message.name == "showReview" {
            handleShowReviewMessage(message)
        }
    }
    
    func handleShowReviewMessage(_ message: WKScriptMessage) {
        self.emptyView.hide()
        self.activityIndicator?.startAnimating()
        let attemptId = message.body
        getAttempt(attemptId as! String)
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
                // Check if the remaining time for the attempt is infinite we reset to default value of 24 hours.
                // This is done because our app doesn't support exams with infinite timing.
                if attempt?.remainingTime == INFINITE_EXAM_TIME {
                    attempt?.remainingTime = DEFAULT_EXAM_TIME
                }
                
                if quizMode {
                    self.goToQuizExam(attempt!)
                } else {
                    self.gotoTestEngine(attempt!)
                }
            })
        
    }
    
    func getAttempt(_ attemptId: String) {
        TPApiClient.request(
            type: Attempt.self,
            endpointProvider: TPEndpointProvider(
                .get,
                url: Constants.BASE_URL+"/api/v2.2/attempts/"+attemptId+"/"
            ),
            completion: {
                attempt, error in
                
                if let error = error {
                    self.showErrorMessage(error: error)
                    return
                }
                if attempt != nil {
                    self.gotoTestReport(attempt!)
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
    
    func gotoTestReport(_ attempt: Attempt) {
        let storyboard = UIStoryboard(name: Constants.EXAM_REVIEW_STORYBOARD, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier:
                Constants.TEST_REPORT_VIEW_CONTROLLER) as! TestReportViewController
        viewController.attempt = attempt
        present(viewController, animated: true, completion: nil)
    }
    
    override func onFinishLoadingWebView() {
        activityIndicator?.stopAnimating()
    }
            
    
}
