//
//  TestEngineViewController.swift
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

class TestEngineViewController: UIViewController, UIPageViewControllerDelegate {
    
    @IBOutlet weak var questionsContainerView: UIView!
    @IBOutlet weak var prevArrow: UIImageView!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nextArrow: UIImageView!
    @IBOutlet weak var nextButtonLayout: UIStackView!
    @IBOutlet weak var previousButtonLayout: UIStackView!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    var pageViewController: UIPageViewController?
    var questionsControllerSource: QuestionsControllerSource?
    var currentIndex: Int?
    var remainingTime: Int = 0
    var timer: Timer = Timer()
    var exam: Exam?
    var attempt: Attempt?
    var attemptItems = [AttemptItem]()
    var showingProgress: Bool = false
    var previousQuestionIndex: Int = 0
    let loadingDialogController = UIUtils.initProgressDialog(message: "Loading questions\n\n")
  
    override func viewDidLoad() {
        super.viewDidLoad()

        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController!.delegate = self
        addChildViewController(self.pageViewController!)
        questionsContainerView.addSubview(self.pageViewController!.view)
        var pageViewRect = questionsContainerView.bounds
        if UIDevice.current.userInterfaceIdiom == .pad {
            pageViewRect = pageViewRect.insetBy(dx: 40.0, dy: 40.0)
        }
        pageViewController!.view.frame = pageViewRect
        pageViewController!.didMove(toParentViewController: self)
        // Set navigation button click listener
        let previousButtonGesture = UITapGestureRecognizer(target: self, action:
            #selector(self.onClickPreviousButton(sender:)))
        previousButtonLayout.addGestureRecognizer(previousButtonGesture)
        let nextButtonGesture = UITapGestureRecognizer(target: self, action:
            #selector(self.onClickNextButton(sender:)))
        nextButtonLayout.addGestureRecognizer(nextButtonGesture)
        prevButton.setTitleColor(UIColor.lightGray, for: .disabled)
        prevButton.setTitleColor(Colors.getRGB(Colors.PRIMARY), for: .normal)
        nextButton.setTitleColor(UIColor.red, for: .disabled)
        nextButton.setTitleColor(Colors.getRGB(Colors.PRIMARY), for: .normal)
        nextButton.setTitle("END", for: .disabled)
        nextButton.setTitle("NEXT", for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if attemptItems.isEmpty {
            self.present(loadingDialogController, animated: false, completion: nil)
            loadQuestions(url: (attempt?.questionsUrl)!)
        }
    }
    
    func loadQuestions(url: String) {
        TPApiClient.getQuestions(
            endpointProvider: TPEndpointProvider(.getQuestions, url: url),
            completion: {
                testpressResponse, error in
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
                    self.loadingDialogController.dismiss(animated: true, completion: nil)
                    return
                }
                self.attemptItems.append(contentsOf: testpressResponse!.results)
                if !(testpressResponse!.next.isEmpty) {
                    self.loadQuestions(url: testpressResponse!.next)
                } else {
                    self.questionsControllerSource = QuestionsControllerSource(self.attemptItems)
                    // TODO: Handle empty questions
                    let startingViewController: QuestionsViewController =
                        self.questionsControllerSource!
                            .viewControllerAtIndex(0, storyboard: self.storyboard!)!
                    
                    let viewControllers = [startingViewController]
                    self.pageViewController!.setViewControllers(
                        viewControllers, direction: .forward, animated: false,
                        completion: {done in })
                    
                    self.pageViewController!.dataSource = self.questionsControllerSource
                    self.setCurrentQuestion(index: self.getCurrentIndex())
                    self.remainingTime = self.getSecondsFromInputString(self.attempt?.remainingTime)
                    self.startTimer()
                    self.loadingDialogController.dismiss(animated: true, completion: nil)
                    // Set loading progress dialog message for further use
                    self.loadingDialogController.message = "Loading…\n\n"
                }
            }
        )
    }
    
    // MARK: - UIPageViewController delegate methods
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        
        // When user swipe the page, set current question
        if completed {
            setCurrentQuestion(index: getCurrentIndex())
        }
    }
    
    func getCurrentIndex() -> Int {
        let currentViewController = self.pageViewController!.viewControllers![0] as! QuestionsViewController
        return (currentViewController.attemptItem?.index)!
    }
    
    func setCurrentQuestion(index: Int) {
        saveAnswer(index: previousQuestionIndex)
        previousQuestionIndex = index
        // Update previous button
        if index == 0 {
            previousButtonLayout.isUserInteractionEnabled = false
            prevButton.isEnabled = false
            prevArrow.tintColor = UIColor.lightGray
        } else {
            previousButtonLayout.isUserInteractionEnabled = true
            prevButton.isEnabled = true
            prevArrow.tintColor = Colors.getRGB(Colors.PRIMARY)
        }
        // Update next button
        if index + 1 == self.questionsControllerSource?.attemptItems.count {
            nextButton.isEnabled = false
            nextArrow.tintColor = UIColor.lightGray
        } else {
            nextButton.isEnabled = true
            nextArrow.tintColor = Colors.getRGB(Colors.PRIMARY)
        }
    }
    
    func onClickPreviousButton(sender : UITapGestureRecognizer) {
        var index = getCurrentIndex()
        if index == 0 {
            return
        }
        index -= 1
        
        let viewControllers = [self.questionsControllerSource?
            .viewControllerAtIndex(index, storyboard: self.storyboard!)] as! [UIViewController]
        self.pageViewController!.setViewControllers(viewControllers , direction: .reverse,
                                                    animated: true, completion: {done in })
        setCurrentQuestion(index: getCurrentIndex())
    }
    
    func onClickNextButton(sender : UITapGestureRecognizer) {
        var  index = getCurrentIndex()
        index += 1
        if index == self.questionsControllerSource?.attemptItems.count {
            onEndExam()
            return
        }
        
        let viewControllers = [self.questionsControllerSource?
            .viewControllerAtIndex(index, storyboard: self.storyboard!)] as! [UIViewController]
        self.pageViewController!.setViewControllers(viewControllers , direction: .forward,
                                                    animated: true, completion: {done in })
        setCurrentQuestion(index: getCurrentIndex())
    }
    
    func updateRemainingTime() {
        if(remainingTime > 0) {
            remainingTime -= 1
            let hours = (remainingTime / (60 * 60)) % 12
            let minutes = (remainingTime / 60) % 60
            let seconds = remainingTime % 60
            remainingTimeLabel.text = String(format: "%d:%02d:%02d", hours, minutes, seconds)
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
            endpointProvider: TPEndpointProvider(.sendHeartBeat, url: attempt!.url! +
                TPEndpoint.sendHeartBeat.urlPath),
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
        self.saveAnswer(index: self.getCurrentIndex(), completionHandler: {
            self.endExam()
        })
    }
    
    func endExam() {
        TPApiClient.updateAttemptState(
            endpointProvider: TPEndpointProvider(
                .endExam,
                url: attempt!.url! + TPEndpoint.endExam.urlPath
            ),
            completion: {
                attempt, error in
                if let error = error {
                    self.showAlert(error: error, retryHandler: { self.endExam() })
                    return
                }
                
                self.attempt = attempt
                self.hideLoadingProgress(completionHandler: {
                    self.gotoTestReport()
                })
            }
        )
    }
    
    func showAlert(error: TPError, retryHandler: @escaping (() -> Swift.Void)) {
        if self.showingProgress {
            // Close progress dialog if currently showing
            self.loadingDialogController.dismiss(animated: true, completion: {
                self.showingProgress = false
                self.showAlert(error: error, retryHandler: retryHandler)
            })
            return
        }
        
        timer.invalidate()
        var alert: UIAlertController
        var cancelButtonTitle: String
        
        if error.kind == .network {
            alert = UIAlertController(
                title: "No internet connection",
                message: "Exam is paused, Please check your internet connection & resume again.",
                preferredStyle: UIAlertControllerStyle.alert
            )
            
            alert.addAction(UIAlertAction(
                title: "Retry", style: UIAlertActionStyle.default, handler: {
                    (action: UIAlertAction!) in
                    alert.dismiss(animated: false)
                    self.present(self.loadingDialogController, animated: true, completion: nil)
                    self.showingProgress = true
                    retryHandler()
            }))
            cancelButtonTitle = "Not Now"
        } else {
            alert = UIAlertController(
                title: "Loading Failed",
                message: "Some thing went wrong, please try again later.",
                preferredStyle: UIAlertControllerStyle.alert
            )
            cancelButtonTitle = "OK"
        }

        alert.addAction(UIAlertAction(
            title: cancelButtonTitle, style: UIAlertActionStyle.default,
            handler: { (action: UIAlertAction!) in
                self.dismiss(animated: true, completion: nil)
            }
        ))
        
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func onPressStopButton(_ sender: UIBarButtonItem) {
        var alert: UIAlertController
    
        alert = UIAlertController(
            title: "Exit Exam",
            message: "Are you sure? you can pause the exam & resume again.",
            preferredStyle: UIAlertControllerStyle.actionSheet
        )
        
        alert.addAction(UIAlertAction(
            title: "Pause", style: UIAlertActionStyle.default, handler: {
                (action: UIAlertAction!) in
                self.showLoadingProgress()
                self.saveAnswer(index: self.getCurrentIndex(), completionHandler: {
                   self.gotoHistory()
                })
        }))
        
        alert.addAction(UIAlertAction(
            title: "End", style: UIAlertActionStyle.default,
            handler: { (action: UIAlertAction!) in
                self.onEndExam()
            }
        ))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func gotoHistory() {
        let presentingViewController = self.presentingViewController?.presentingViewController
        if presentingViewController is TabViewController {
            let tabViewController = presentingViewController as! TabViewController
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
                attemptsListViewController.loadAttemptsWithProgress()
            })
        }
    }
    
    func gotoTestReport() {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier:
            Constants.TEST_REPORT_VIEW_CONTROLLER) as! TestReportViewController
        viewController.exam = exam
        viewController.attempt = attempt
        self.present(viewController, animated: true, completion: nil)
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
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:
            #selector(self.updateRemainingTime), userInfo: nil, repeats: true)
    }
    
    func showLoadingProgress() {
        timer.invalidate()
        present(self.loadingDialogController, animated: true)
        showingProgress = true
    }
    
    func hideLoadingProgress(completionHandler: (() -> Void)? = nil) {
        if self.showingProgress {
            self.loadingDialogController.dismiss(animated: false, completion: {
                if completionHandler != nil {
                    completionHandler!()
                }
            })
            self.showingProgress = false
        } else {
            if completionHandler != nil {
                completionHandler!()
            }
        }
    }
}
