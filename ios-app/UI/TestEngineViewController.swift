//
//  TestEngineViewController.swift
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

class TestEngineViewController: BaseQuestionsPageViewController {
    
    var remainingTime: Int = 0
    var timer: Timer = Timer()
    var parentSlidingViewController: TestEngineSlidingViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionsPageViewDelegate = self
        nextButton.setTitleColor(Colors.getRGB(Colors.MATERIAL_RED), for: .disabled)
        nextButton.setTitle("END", for: .disabled)
        nextButton.setTitle("NEXT", for: .normal)
        
        let pauseButtonGesture = UITapGestureRecognizer(target: self, action:
            #selector(self.onPressPauseButton(sender:)))
        parentSlidingViewController.pauseButtonLayout.addGestureRecognizer(pauseButtonGesture)
    }
    
    override func getQuestionsDataSource() -> BaseQuestionsDataSource {
        return QuestionsControllerSource(attemptItems)
    }
    
    override func onClickNextButton(sender: UITapGestureRecognizer) {
        var  index = getCurrentIndex()
        index += 1
        if index == baseQuestionsDataSource.attemptItems.count {
            onPressStopButton()
            return
        }
        
        super.onClickNextButton(sender: sender)
    }
    
    @objc func updateRemainingTime() {
        if(remainingTime > 0) {
            remainingTime -= 1
            let hours = (remainingTime / (60 * 60)) % 12
            let minutes = (remainingTime / 60) % 60
            let seconds = remainingTime % 60
            parentSlidingViewController.remainingTimeLabel.text =
                String(format: "%d:%02d:%02d", hours, minutes, seconds)
            
            if hours != 0 || minutes != 0 || seconds != 0 {
                if (remainingTime % 60) == 0 {
                    sendHeartBeat();
                }
                return
            }
        }
        onEndExam()
    }
    
    func sendHeartBeat() {
        TPApiClient.updateAttemptState(
            endpointProvider: TPEndpointProvider(
                .sendHeartBeat,
                url: attempt!.url! + TPEndpoint.sendHeartBeat.urlPath
            ),
            completion: {
                attempt, error in
                if let error = error {
                    self.showAlert(error: error, retryHandler: { self.sendHeartBeat() })
                    return
                }
                
                if self.showingProgress {
                    self.startTimer()
                    self.loadingDialogController.dismiss(animated: true)
                    self.showingProgress = false
                }
            }
        )
    }
    
    func saveAnswer(index: Int, completionHandler: (() -> Void)? = nil) {
        let attemptItem = attemptItems[index]
        if attemptItem.hasChanged() {
            TPApiClient.saveAnswer(
                selectedAnswer: attemptItem.savedAnswers, review: attemptItem.currentReview!,
                endpointProvider: TPEndpointProvider(.saveAnswer, url: attemptItem.url!),
                completion: {
                    newAttemptItem, error in
                    if let error = error {
                        self.showAlert(error: error, retryHandler: {
                            self.saveAnswer(index: index, completionHandler: completionHandler)
                        })
                        return
                    }
                    
                    if completionHandler != nil {
                        // Saved the answer on user paused or end the exam
                        self.hideLoadingProgress(completionHandler: completionHandler)
                        return
                    }
                    // Saved the answer on user navigate to other question
                    attemptItem.selectedAnswers = newAttemptItem!.selectedAnswers
                    attemptItem.review = newAttemptItem!.review
                    self.attemptItems[index] = attemptItem;
                    
                    if self.showingProgress {
                        self.startTimer()
                        self.loadingDialogController.dismiss(animated: false)
                        self.showingProgress = false
                    }
                }
            )
        } else {
            hideLoadingProgress(completionHandler: completionHandler)
        }
    }
    
    func onEndExam() {
        showLoadingProgress()
        saveAnswer(index: getCurrentIndex(), completionHandler: {
            self.endExam()
        })
    }
    
    func endExam() {
        var endpointProvider: TPEndpointProvider
        if contentAttempt != nil {
            endpointProvider = TPEndpointProvider(.put, url: contentAttempt.getEndAttemptUrl())
            endExam(type: ContentAttempt.self, endpointProvider: endpointProvider)
        } else {
            endpointProvider = TPEndpointProvider(
                .put,
                url: attempt!.url! + TPEndpoint.endExam.urlPath
            )
            endExam(type: Attempt.self, endpointProvider: endpointProvider)
        }
    }
    
    func endExam<T: TestpressModel>(type: T.Type, endpointProvider: TPEndpointProvider) {
        TPApiClient.request(
            type: type,
            endpointProvider: endpointProvider,
            completion: {
                attempt, error in
                if let error = error {
                    self.showAlert(error: error, retryHandler: { self.endExam() })
                    return
                }
                
                if attempt is ContentAttempt {
                    self.contentAttempt = attempt as! ContentAttempt
                    self.attempt = self.contentAttempt.assessment
                } else {
                    self.attempt = attempt as? Attempt
                }
                self.hideLoadingProgress(completionHandler: {
                    self.gotoTestReport()
                })
        }
        )
    }
    
    override func showAlert(error: TPError, retryHandler: @escaping (() -> Swift.Void)) {
        timer.invalidate()
        super.showAlert(error: error, retryHandler: retryHandler)
    }
    
    @objc func onPressPauseButton(sender: UITapGestureRecognizer) {
        let alert = UIAlertController(title: Strings.EXIT_EXAM,
                                      message: Strings.PAUSE_MESSAGE,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(
            title: Strings.YES,
            style: UIAlertActionStyle.default,
            handler: { action in
                self.showLoadingProgress()
                self.saveAnswer(index: self.getCurrentIndex(), completionHandler: {
                    self.goBack()
                })
            }
        ))
        alert.addAction(UIAlertAction(title: Strings.CANCEL, style: UIAlertActionStyle.cancel))
        present(alert, animated: true, completion: {
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action:
                #selector(self.closeAlert(gesture:))))
        })
    }
    
    @objc func closeAlert(gesture: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    func onPressStopButton() {
        var alert: UIAlertController
        alert = UIAlertController(
            title: Strings.EXIT_EXAM,
            message: Strings.END_MESSAGE,
            preferredStyle: UIUtils.getActionSheetStyle()
        )
        alert.addAction(UIAlertAction(
            title: Strings.PAUSE, style: UIAlertActionStyle.default, handler: {
                (action: UIAlertAction!) in
                self.showLoadingProgress()
                self.saveAnswer(index: self.getCurrentIndex(), completionHandler: {
                    self.goBack()
                })
            }
        ))
        alert.addAction(UIAlertAction(
            title: Strings.END, style: UIAlertActionStyle.destructive,
            handler: { (action: UIAlertAction!) in
                self.onEndExam()
            }
        ))
        alert.addAction(UIAlertAction(title: Strings.CANCEL, style: UIAlertActionStyle.cancel))
        present(alert, animated: true, completion: nil)
    }
    
    func gotoTestReport() {
        let storyboard = UIStoryboard(name: Constants.EXAM_REVIEW_STORYBOARD, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier:
            Constants.TEST_REPORT_VIEW_CONTROLLER) as! TestReportViewController
        
        viewController.exam = exam
        viewController.attempt = attempt
        present(viewController, animated: true, completion: nil)
    }
    
    func getSecondsFromInputString(_ inputString: String?) -> Int {
        if inputString == nil {
            return 0
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        guard let date = dateFormatter.date(from: inputString!) else {
            assert(false, "no date from string")
            return 0
        }
        
        return Int(date.timeIntervalSince1970)
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:
            #selector(self.updateRemainingTime), userInfo: nil, repeats: true)
        
        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
    }
    
    override func showLoadingProgress() {
        timer.invalidate()
        super.showLoadingProgress()
    }

}

extension TestEngineViewController: QuestionsPageViewDelegate {
    
    func questionsDidLoad() {
        remainingTime = getSecondsFromInputString(attempt.remainingTime)
        startTimer()
    }
    
    func currentQuestionDidChange(previousIndex: Int, currentIndex: Int) {
         saveAnswer(index: previousIndex)
    }
    
    func goBack() {
        let presentingViewController = self.presentingViewController?.presentingViewController
        if self.presentingViewController! is ContentDetailPageViewController {
            
            let contentDetailPageViewController  =
                self.presentingViewController! as! ContentDetailPageViewController
            
            contentDetailPageViewController.dismiss(animated: false, completion: {
                contentDetailPageViewController.updateCurrentExamContent()
            })
        } else if presentingViewController is UITabBarController {
            let tabViewController =
                presentingViewController?.childViewControllers[0] as! ExamsTabViewController
            
            tabViewController.dismiss(animated: false, completion: {
                if tabViewController.currentIndex != 2 {
                    // Move to histroy tab
                    tabViewController.moveToViewController(at: 2, animated: true)
                }
                // Refresh the list items
                tabViewController.reloadPagerTabStripView()
            })
        } else if presentingViewController is AttemptsListViewController {
            let attemptsListViewController = presentingViewController as! AttemptsListViewController
            attemptsListViewController.dismiss(animated: false, completion: {
                // Remove exsiting items
                attemptsListViewController.attempts.removeAll()
                // Load new attempts list with progress
                attemptsListViewController.loadAttemptsWithProgress(url: self.exam!.attemptsUrl!)
            })
        } else if presentingViewController is ContentDetailPageViewController {
            
            let contentDetailPageViewController =
                presentingViewController as! ContentDetailPageViewController
            
            contentDetailPageViewController.dismiss(animated: false, completion: {
                contentDetailPageViewController.updateCurrentExamContent()
            })
        } else {
            debugPrint(type(of: presentingViewController!))
            dismiss(animated: true, completion: nil)
        }
    }
}

extension TestEngineViewController: SlidingMenuDelegate {
    
    func dismissViewController() {
        onPressStopButton()
    }
}

