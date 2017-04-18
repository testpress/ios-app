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
    let alertController = UIUtils.initProgressDialog(message: "Loading questions\n\n")
  
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
        nextButton.setTitleColor(UIColor.lightGray, for: .disabled)
        nextButton.setTitleColor(Colors.getRGB(Colors.PRIMARY), for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.present(alertController, animated: false, completion: nil)
        loadQuestions(url: (attempt?.questionsUrl)!)
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
                    self.alertController.dismiss(animated: true, completion: nil)
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
                    self.alertController.dismiss(animated: true, completion: nil)
                }
            }
        )
    }
    
    // MARK: - UIPageViewController delegate methods
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
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
        
        if index == 0 {
            previousButtonLayout.isUserInteractionEnabled = false
            prevButton.isEnabled = false
            prevArrow.tintColor = UIColor.lightGray
        } else {
            previousButtonLayout.isUserInteractionEnabled = true
            prevButton.isEnabled = true
            prevArrow.tintColor = Colors.getRGB(Colors.PRIMARY)
        }
        if index + 1 == self.questionsControllerSource?.attemptItems.count {
            nextButtonLayout.isUserInteractionEnabled = false
            nextButton.isEnabled = false
            nextArrow.tintColor = UIColor.lightGray
        } else {
            nextButtonLayout.isUserInteractionEnabled = true
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
            if (remainingTime % 60) == 0 {
                sendHeartBeat();
            }
        } else {
            // TODO: End Exam
        }
    }
    
    func sendHeartBeat() {
        TPApiClient.sendHeartBeat(
            endpointProvider: TPEndpointProvider(.sendHeartBeat, url: attempt!.url! +
                TPEndpoint.sendHeartBeat.urlPath),
            completion: {
                attempt, error in
                if let error = error {
                    self.showAlert(error: error, handler: {
                        self.sendHeartBeat()
                    })
                    return
                }
                
                if self.showingProgress {
                    self.startTimer()
                    self.alertController.dismiss(animated: true)
                    self.showingProgress = false
                }
            }
        )
    }
    
    func saveAnswer(index: Int) {
        let attemptItem = attemptItems[index]
        if attemptItem.hasChanged() {
            TPApiClient.saveAnswer(
                selectedAnswer: attemptItem.savedAnswers, review: attemptItem.currentReview!,
                endpointProvider: TPEndpointProvider(.saveAnswer, url: attemptItem.url!),
                completion: {
                    newAttemptItem, error in
                    if let error = error {
                        self.showAlert(error: error, handler: {
                            self.saveAnswer(index: index)
                        })
                        return
                    }
                    
                    attemptItem.selectedAnswers = newAttemptItem!.selectedAnswers
                    attemptItem.review = newAttemptItem!.review
                    self.attemptItems[index] = attemptItem;
                    if self.showingProgress {
                        self.startTimer()
                        self.alertController.dismiss(animated: true)
                        self.showingProgress = false
                    }
                }
            )
        }
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
    
    func showAlert(error: TPError, handler: @escaping (() -> Swift.Void)) {
        if self.showingProgress {
            self.alertController.dismiss(animated: true, completion: {
                self.showingProgress = false
                self.showAlert(error: error, handler: handler)
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
                    self.alertController.message = "Loading…"
                    alert.dismiss(animated: false)
                    self.present(self.alertController, animated: true, completion: nil)
                    self.showingProgress = true
                    handler()
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
    
    func startTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:
            #selector(self.updateRemainingTime), userInfo: nil, repeats: true)
    }

    @IBAction func onBackPress(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
