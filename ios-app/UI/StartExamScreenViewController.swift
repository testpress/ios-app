//
//  StartExamScreenViewController.swift
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
    var exam: Exam?
    var attempt: Attempt?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emptyView = EmptyView.getInstance(parentView: scrollView)
        view.addSubview(emptyView)
        examTitle.text = exam?.title!
        questionsCount.text = String(describing: (exam?.numberOfQuestions)!)
        if attempt?.remainingTime! != nil {
            duration.text = attempt?.remainingTime!
            durationLabel.text = "Time Remaining"
        } else {
            duration.text = exam?.duration
        }
        markPerQuestion.text = exam?.markPerQuestion
        negativeMarks.text = exam?.negativeMarks
        startEndDate.text = FormatDate.format(dateString: exam?.startDate) + " -\n" +
            FormatDate.format(dateString: exam?.endDate)
        
        if exam?.description != nil {
            descriptionLabel.text = exam?.description
        } else {
            descriptionLabel.isHidden = true
        }
        if exam?.deviceAccessControl == "web" {
            // Hide start button for web only exams
            startButtonLayout.isHidden = true
        } else {
            webOnlyExamLabel.isHidden = true
            if !exam!.hasStarted() {
                startButtonLayout.isHidden = true
            } else if attempt?.state! == Constants.STATE_RUNNING {
                startButton.setTitle("RESUME", for: .normal)
                navigationBarItem.title = Strings.RESUME_EXAM
            }
        }
    }

    @IBAction func startExam(_ sender: UIButton) {
        self.present(alertController, animated: false, completion: nil)
        startButton.isHidden = true
        startAttempt()
    }
    
    @IBAction func back() {
        dismiss(animated: true, completion: nil)
    }
    
    func startAttempt() {
        var endpointProvider: TPEndpointProvider
        if attempt == nil {
            endpointProvider = TPEndpointProvider(
                .createAttempt,
                url: (exam?.attemptsUrl)!
            )
        } else {
            endpointProvider = TPEndpointProvider(
                .resumeAttempt,
                url: attempt!.url! + TPEndpoint.resumeAttempt.urlPath
            )
        }
        TPApiClient.updateAttemptState(
            endpointProvider: endpointProvider,
            completion: {
                attempt, error in
                
                if let error = error {
                    debugPrint(error.message ?? "No error")
                    debugPrint(error.kind)
                    var retryButtonText: String
                    var retryHandler: () -> Void
                    if error.kind == .network {
                        retryButtonText = Strings.TRY_AGAIN
                        retryHandler = {
                            self.present(self.alertController, animated: false, completion: nil)
                            self.startAttempt()
                        }
                    } else {
                        retryButtonText = Strings.OK
                        retryHandler = {
                            self.back()
                        }
                    }
                    let (image, title, description) = error.getDisplayInfo()
                    self.emptyView.show(image: image, title: title, description: description,
                                        retryButtonText: retryButtonText, retryHandler: retryHandler)
                    
                    self.alertController.dismiss(animated: true, completion: nil)
                    return
                }
                
                self.alertController.dismiss(animated: true, completion: nil)
                self.gotoTestEngine(attempt: attempt!)
            }
        )
    }
    
    func gotoTestEngine(attempt: Attempt) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier:
            Constants.TEST_ENGINE_VIEW_CONTROLLER) as! TestEngineViewController
        viewController.exam = exam
        viewController.attempt = attempt
        self.present(viewController, animated: true, completion: nil)
    }
    
    // Set frames of the views in this method to support both portrait & landscape view
    override func viewDidLayoutSubviews() {
        // Add gradient shadow layer to the shadow container view
        let bottomGradient = CAGradientLayer()
        bottomGradient.frame = bottomShadowView.bounds
        bottomGradient.colors = [UIColor.white.cgColor, UIColor.black.cgColor]
        bottomShadowView.layer.insertSublayer(bottomGradient, at: 0)
        
        // Set scroll view content height to support the scroll
        scrollView.contentSize.height = contentView.frame.size.height
    }
    
}
