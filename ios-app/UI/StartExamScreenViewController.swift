//
//  StartExamScreenViewController.swift
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

import SlideMenuControllerSwift
import UIKit

class StartExamScreenViewController: UIViewController {

    @IBOutlet weak var examTitle: UILabel!
    @IBOutlet weak var questionsCount: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var markPerQuestion: UILabel!
    @IBOutlet weak var negativeMarks: UILabel!
    @IBOutlet weak var startEndDate: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var webOnlyExamLabel: UILabel!
    @IBOutlet weak var bottomShadowView: UIView!
    @IBOutlet weak var startButtonLayout: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIStackView!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    
    let alertController = UIUtils.initProgressDialog(message: "Please wait\n\n")
    var emptyView: EmptyView!
    var content: Content!
    var contentAttempt: ContentAttempt!
    var exam: Exam!
    var attempt: Attempt?
    var accessCode: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStatusBarColor()
        
        emptyView = EmptyView.getInstance(parentView: scrollView)
        view.addSubview(emptyView)
        if content != nil && exam == nil {
            exam = content.exam
            if contentAttempt != nil && attempt == nil {
                attempt = contentAttempt.assessment
            }
        }
        examTitle.text = exam.title
        questionsCount.text = String(exam.numberOfQuestions)
        if attempt?.remainingTime != nil {
            duration.text = attempt?.remainingTime!
            durationLabel.text = "Time Remaining"
        } else {
            duration.text = exam?.duration
        }
        markPerQuestion.text = exam?.markPerQuestion
        negativeMarks.text = exam?.negativeMarks
        startEndDate.text = FormatDate.format(dateString: exam?.startDate) + " -\n" +
            FormatDate.format(dateString: exam?.endDate)
        
        if exam?.examDescription != nil {
            descriptionLabel.text = exam?.examDescription
        } else {
            descriptionLabel.isHidden = true
        }
        if exam?.deviceAccessControl == "web" {
            // Hide start button for web only exams
            startButtonLayout.isHidden = true
        } else if content != nil && content.isLocked {
            webOnlyExamLabel.text = Strings.SCORE_GOOD_IN_PREVIOUS
            startButtonLayout.isHidden = true
        } else if !exam!.hasStarted() {
            webOnlyExamLabel.text =
                Strings.CAN_START_EXAM_ONLY_AFTER + FormatDate.format(dateString: exam?.startDate)
            
            startButtonLayout.isHidden = true
        } else if exam.hasEnded() {
            webOnlyExamLabel.text = Strings.EXAM_ENDED
            startButtonLayout.isHidden = true
        } else {
            webOnlyExamLabel.isHidden = true
            UIUtils.setButtonDropShadow(startButton)
            if attempt?.state! == Constants.STATE_RUNNING {
                startButton.setTitle("RESUME", for: .normal)
                navigationBarItem?.title = Strings.RESUME_EXAM
            }
        }
    }
    
    @IBAction func startExam(_ sender: UIButton) {
        present(alertController, animated: false, completion: nil)
        startButton.isHidden = true
        startAttempt()
    }
    
    @IBAction func back() {
        dismiss(animated: true, completion: nil)
    }
    
    func startAttempt() {
        var endpointProvider: TPEndpointProvider
        if content != nil && contentAttempt == nil {
            endpointProvider = TPEndpointProvider(
                .post,
                url: content.getAttemptsUrl()
            )
            startAttempt(type: ContentAttempt.self, endpointProvider: endpointProvider)
            return
        } else if attempt == nil {
            var queryParams = [String: String]()
            if accessCode != nil {
                queryParams.updateValue(accessCode, forKey: Constants.ACCESS_CODE)
            }
            endpointProvider = TPEndpointProvider(
                .post,
                url: (exam?.attemptsUrl)!,
                queryParams: queryParams
            )
        } else {
            endpointProvider = TPEndpointProvider(
                .put,
                url: attempt!.url + TPEndpoint.resumeAttempt.urlPath
            )
        }
        startAttempt(type: Attempt.self, endpointProvider: endpointProvider)
    }
    
    func startAttempt<T: TestpressModel>(type: T.Type, endpointProvider: TPEndpointProvider) {
        TPApiClient.request(
            type: type,
            endpointProvider: endpointProvider,
            completion: {
                attempt, error in
                
                if let error = error {
                    debugPrint(error.message ?? "No error")
                    debugPrint(error.kind)
                    var retryButtonText: String?
                    var retryHandler: (() -> Void)?
                    if error.kind == .network {
                        retryButtonText = Strings.TRY_AGAIN
                        retryHandler = {
                            self.present(self.alertController, animated: false, completion: nil)
                            self.startAttempt()
                        }
                    }
                    let (image, title, description) = error.getDisplayInfo()
                    self.emptyView.show(image: image, title: title, description: description,
                                        retryButtonText: retryButtonText,
                                        retryHandler: retryHandler)
                    
                    self.alertController.dismiss(animated: true, completion: nil)
                    return
                }
                
                self.alertController.dismiss(animated: true, completion: nil)
                if let contentAttempt = attempt as? ContentAttempt {
                    self.contentAttempt = contentAttempt
                    self.content.attemptsCount += 1
                    self.attempt = contentAttempt.assessment
                } else {
                    self.attempt = attempt as? Attempt
                }
                self.gotoTestEngine()
        })
    }
    
    func gotoTestEngine() {
        let storyboard = UIStoryboard(name: Constants.TEST_ENGINE, bundle: nil)
        let slideMenuController = storyboard.instantiateViewController(withIdentifier:
            Constants.TEST_ENGINE_NAVIGATION_CONTROLLER) as! UINavigationController
        
        let viewController =
            slideMenuController.viewControllers.first as! TestEngineSlidingViewController
        
        viewController.exam = exam
        viewController.attempt = attempt
        viewController.courseContent = content
        viewController.contentAttempt = contentAttempt
        present(slideMenuController, animated: true, completion: nil)
    }
    
    // Set frames of the views in this method to support both portrait & landscape view
    override func viewDidLayoutSubviews() {
        // Add gradient shadow layer to the shadow container view
        if bottomShadowView != nil {
            let bottomGradient = CAGradientLayer()
            bottomGradient.frame = bottomShadowView.bounds
            bottomGradient.colors = [UIColor.white.cgColor, UIColor.black.cgColor]
            bottomShadowView.layer.insertSublayer(bottomGradient, at: 0)
        }
        
        // Set scroll view content height to support the scroll
        scrollView.contentSize.height = contentView.frame.size.height
    }
    
}
