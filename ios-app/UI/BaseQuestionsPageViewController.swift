//
//  BaseQuestionsPageViewController.swift
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

@objc protocol QuestionsPageViewDelegate {
    @objc optional func questionsDidLoad()
    @objc optional func currentQuestionDidChange(previousIndex: Int, currentIndex: Int)
    func goBack()
}

class BaseQuestionsPageViewController: UIViewController, UIPageViewControllerDelegate {
    
    @IBOutlet weak var questionsContainerView: UIView!
    @IBOutlet weak var prevArrow: UIImageView!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nextArrow: UIImageView!
    @IBOutlet weak var nextButtonLayout: UIStackView!
    @IBOutlet weak var previousButtonLayout: UIStackView!
    
    var pageViewController: UIPageViewController!
    var baseQuestionsDataSource: BaseQuestionsDataSource!
    var questionsPageViewDelegate: QuestionsPageViewDelegate?
    var parentviewController: BaseQuestionsSlidingViewController!
    var currentIndex: Int!
    var exam: Exam!
    var attempt: Attempt!
    var attemptItems = [AttemptItem]()
    var courseContent: Content!
    var contentAttempt: ContentAttempt!
    var showingProgress: Bool = false
    let loadingDialogController = UIUtils.initProgressDialog(message: Strings.LOADING_QUESTIONS)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                  navigationOrientation: .horizontal,
                                                  options: nil)
        
        pageViewController.delegate = self
        addChildViewController(pageViewController)
        questionsContainerView.addSubview(pageViewController.view)
        pageViewController.view.frame = questionsContainerView.bounds
        pageViewController.didMove(toParentViewController: self)
        // Set navigation buttons click listener
        let previousButtonGesture = UITapGestureRecognizer(target: self, action:
            #selector(self.onClickPreviousButton(sender:)))
        previousButtonLayout.addGestureRecognizer(previousButtonGesture)
        let nextButtonGesture = UITapGestureRecognizer(target: self, action:
            #selector(self.onClickNextButton(sender:)))
        nextButtonLayout.addGestureRecognizer(nextButtonGesture)
        // Set navigation buttons text color
        prevButton.setTitleColor(UIColor.lightGray, for: .disabled)
        prevButton.setTitleColor(Colors.getRGB(Colors.PRIMARY), for: .normal)
        nextButton.setTitleColor(UIColor.lightGray, for: .disabled)
        nextButton.setTitleColor(Colors.getRGB(Colors.PRIMARY), for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if attemptItems.isEmpty {
            showLoadingProgress(completionHandler: {
                self.loadQuestions(url: self.getQuestionsUrl())
            })
        }
    }
    
    func getQuestionsUrl() -> String {
        return (attempt?.questionsUrl)!
    }
    
    func getQuestionsDataSource() -> BaseQuestionsDataSource {
        return BaseQuestionsDataSource(attemptItems)
    }
    
    func loadQuestions(url: String) {
        if loadingDialogController.message!.contains(Strings.PLEASE_WAIT) {
            loadingDialogController.message = Strings.LOADING_QUESTIONS + "\n\n"
        }
        TPApiClient.getQuestions(
            endpointProvider: TPEndpointProvider(.getQuestions, url: url),
            completion: {
                testpressResponse, error in
                if let error = error {
                    debugPrint(error.message ?? "No error message found")
                    debugPrint(error.kind)
                    self.showAlert(error: error, retryHandler: {
                        self.loadQuestions(url: url)
                    })
                    return
                }
                self.attemptItems.append(contentsOf: testpressResponse!.results)
                if !(testpressResponse!.next.isEmpty) {
                    self.loadQuestions(url: testpressResponse!.next)
                } else {
                    if self.attemptItems.isEmpty {
                        // Handled empty questions
                        self.loadingDialogController.dismiss(animated: true, completion: {
                            UIUtils.showSimpleAlert(
                                title: Strings.NO_QUESTIONS,
                                message: Strings.NO_QUESTIONS_DESCRIPTION,
                                viewController: self,
                                completion: { action in
                                    self.questionsPageViewDelegate?.goBack()
                                }
                            )
                        })
                        return
                    }
                    self.attemptItems = self.attemptItems.sorted(by: { $0.order! < $1.order! })
                    self.baseQuestionsDataSource = self.getQuestionsDataSource()
                    // TODO: Handle empty questions
                    let startingViewController: BaseQuestionsViewController =
                        self.baseQuestionsDataSource.viewControllerAtIndex(0)!
                    let viewControllers = [startingViewController]
                    self.pageViewController.setViewControllers(
                        viewControllers, direction: .forward, animated: false,
                        completion: {done in })
                    
                    self.pageViewController.dataSource = self.baseQuestionsDataSource
                    self.updateNavigationButtons(index: self.getCurrentIndex())
                    self.parentviewController
                        .questionsSlidingMenuDelegate.updateQuestions(self.attemptItems)
                    
                    self.hideLoadingProgress(completionHandler: {
                        if self.questionsPageViewDelegate?.questionsDidLoad != nil {
                            self.questionsPageViewDelegate?.questionsDidLoad!()
                        }
                    })
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
            let currentIndex = getCurrentIndex()
            if questionsPageViewDelegate != nil {
                let previousViewController = previousViewControllers[0] as!
                    BaseQuestionsViewController
                
                let previousIndex = (previousViewController.attemptItem?.index)!
                if questionsPageViewDelegate?.currentQuestionDidChange != nil {
                    questionsPageViewDelegate?.currentQuestionDidChange!(
                        previousIndex: previousIndex, currentIndex: currentIndex)
                }
            }
            updateNavigationButtons(index: currentIndex)
        }
    }
    
    func getCurrentIndex() -> Int {
        let currentViewController = pageViewController.viewControllers![0] as!
            BaseQuestionsViewController
        
        return (currentViewController.attemptItem?.index)!
    }
    
    func setCurrentQuestion(index: Int) {
        let currentIndex: Int = getCurrentIndex()
        if  index < 0 || index >= (baseQuestionsDataSource?.attemptItems.count)! ||
                index == currentIndex {
            
            return
        }
        let viewController =
            [baseQuestionsDataSource?.viewControllerAtIndex(index)] as! [UIViewController]
        
        let direction: UIPageViewControllerNavigationDirection =
            index > currentIndex ? .forward : .reverse
        
        pageViewController.setViewControllers(viewController , direction: direction,
                                              animated: true, completion: {done in })
        
        
        if questionsPageViewDelegate?.currentQuestionDidChange != nil {
            questionsPageViewDelegate?
                .currentQuestionDidChange!(previousIndex: currentIndex, currentIndex: index)
        }
        updateNavigationButtons(index: index)
    }
    
    func updateNavigationButtons(index: Int) {
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
        if index + 1 == baseQuestionsDataSource?.attemptItems.count {
            nextButton.isEnabled = false
            nextArrow.tintColor = UIColor.lightGray
        } else {
            nextButton.isEnabled = true
            nextArrow.tintColor = Colors.getRGB(Colors.PRIMARY)
        }
    }
    
    @objc func onClickPreviousButton(sender: UITapGestureRecognizer) {
        setCurrentQuestion(index: getCurrentIndex() - 1)
    }
    
    @objc func onClickNextButton(sender: UITapGestureRecognizer) {
        setCurrentQuestion(index: getCurrentIndex() + 1)
    }
    
    @IBAction func showQuestionListPanel(_ sender: UIButton) {
        parentviewController.slideMenuController()?.openLeft()
    }
    
    func showAlert(error: TPError,
                   message: String = Strings.PLEASE_CHECK_INTERNET_CONNECTION,
                   retryHandler: @escaping (() -> Swift.Void)) {
        
        if showingProgress {
            // Close progress dialog if currently showing
            hideLoadingProgress(completionHandler: {
                self.showAlert(error: error, retryHandler: retryHandler)
            })
            return
        }
        
        var alert: UIAlertController
        var cancelButtonTitle: String
        
        if error.kind == .network {
            alert = UIAlertController(
                title: "No internet connection",
                message: message,
                preferredStyle: UIAlertControllerStyle.alert
            )
            
            alert.addAction(UIAlertAction(
                title: "Retry", style: UIAlertActionStyle.default, handler: {
                    (action: UIAlertAction!) in
                    alert.dismiss(animated: false)
                    self.showLoadingProgress(completionHandler: {
                        retryHandler()
                    })
                }
            ))
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
                self.questionsPageViewDelegate?.goBack()
            }
        ))
        
        present(alert, animated: true, completion: nil)
    }
    
    func showLoadingProgress(completionHandler: (() -> Void)?) {
        loadingDialogController.message = Strings.PLEASE_WAIT + "\n\n"
        present(loadingDialogController, animated: false, completion: {
            self.showingProgress = true
            if completionHandler != nil {
                completionHandler!()
            }
        })
    }
    
    func hideLoadingProgress(completionHandler: (() -> Void)? = nil) {
        if showingProgress {
            loadingDialogController.dismiss(animated: false, completion: {
                self.showingProgress = false
                if completionHandler != nil {
                    completionHandler!()
                }
            })
        } else {
            if completionHandler != nil {
                completionHandler!()
            }
        }
    }
    
}

extension BaseQuestionsPageViewController: QuestionListDelegate {
    
    func gotoQuestion(index: Int) {
        parentviewController.slideMenuController()?.closeLeft()
        setCurrentQuestion(index: index)
    }
}

