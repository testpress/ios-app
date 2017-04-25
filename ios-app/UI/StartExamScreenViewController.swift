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
    
    let alertController = UIUtils.initProgressDialog(message: "Please wait\n\n")
    var exam: Exam?
    var attempt: Attempt?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        if attempt?.state! == Constants.STATE_RUNNING {
            startButton.setTitle("RESUME", for: .normal)
        }
    }

    @IBAction func startExam(_ sender: UIButton) {
        self.present(alertController, animated: false, completion: nil)
        if attempt != nil {
            resumeAttempt()
        } else {
            createAttempt()
        }
    }
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func createAttempt() {
        TPApiClient.createAttempt(
            endpointProvider: TPEndpointProvider(.createAttempt, url: (exam?.attemptsUrl)!),
            completion: {
                attempt, error in
                
                if let error = error {
                    print(error.message ?? "No error")
                    print(error.kind)
                    switch (error.kind) {
                    case .network:
                        print("Internet Unavailable")
                    case .unauthenticated:
                        print("Authorization Required")
                    case .http:
                        print("HTTP error occured")
                    default:
                        print("Unexpected")
                    }
                    self.alertController.dismiss(animated: true, completion: nil)
                    return
                }
                
                self.alertController.dismiss(animated: true, completion: nil)
                self.gotoTestEngine(attempt: attempt!)
            }
        )
    }
    
    func resumeAttempt() {
        TPApiClient.updateAttemptState(
            endpointProvider: TPEndpointProvider(
                .resumeAttempt,
                url: attempt!.url! + TPEndpoint.resumeAttempt.urlPath
            ),
            completion: {
                attempt, error in
                
                if let error = error {
                    print(error.message ?? "No error")
                    print(error.kind)
                    switch (error.kind) {
                    case .network:
                        print("Internet Unavailable")
                    case .unauthenticated:
                        print("Authorization Required")
                    case .http:
                        print("HTTP error occured")
                    default:
                        print("Unexpected")
                    }
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
    
}
