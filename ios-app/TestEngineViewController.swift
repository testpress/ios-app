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
    var pageViewController: UIPageViewController?
    var questionsControllerSource: QuestionsControllerSource?
    var currentIndex: Int?
    var exam: Exam?
    var attempt: Attempt?
    var attemptItems = [AttemptItem]()
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
                    self.updateNavigationButtonState()
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
            updateNavigationButtonState()
        }
    }
    
    func getCurrentIndex() -> Int? {
        let currentViewController = self.pageViewController!.viewControllers![0] as! QuestionsViewController
        return currentViewController.attemptItem?.index
    }
    
    func updateNavigationButtonState() {
        if getCurrentIndex() == 0 {
            previousButtonLayout.isUserInteractionEnabled = false
            prevButton.titleLabel?.textColor = UIColor.lightGray
            prevArrow.tintColor = UIColor.lightGray
        } else {
            previousButtonLayout.isUserInteractionEnabled = true
            prevButton.titleLabel?.textColor = Colors.getRGB(Colors.PRIMARY)
            prevArrow.tintColor = Colors.getRGB(Colors.PRIMARY)
        }
        if getCurrentIndex()! + 1 == self.questionsControllerSource?.attemptItems.count {
            nextButtonLayout.isUserInteractionEnabled = false
            nextButton.titleLabel?.textColor = UIColor.lightGray
            nextArrow.tintColor = UIColor.lightGray
        } else {
            nextButtonLayout.isUserInteractionEnabled = true
            nextButton.titleLabel?.textColor = Colors.getRGB(Colors.PRIMARY)
            nextArrow.tintColor = Colors.getRGB(Colors.PRIMARY)
        }
    }
    
    func onClickPreviousButton(sender : UITapGestureRecognizer) {
        var index = getCurrentIndex()
        if (index == 0) || (index == nil) {
            return
        }
        index! -= 1
        
        let viewControllers = [self.questionsControllerSource?
            .viewControllerAtIndex(index!, storyboard: self.storyboard!)] as! [UIViewController]
        self.pageViewController!.setViewControllers(viewControllers , direction: .reverse,
                                                    animated: true, completion: {done in })
        updateNavigationButtonState()
    }
    
    func onClickNextButton(sender : UITapGestureRecognizer) {
        var  index = getCurrentIndex()
        if index == nil {
            return
        }
        index! += 1
        if index == self.questionsControllerSource?.attemptItems.count {
            return
        }
        
        let viewControllers = [self.questionsControllerSource?
            .viewControllerAtIndex(index!, storyboard: self.storyboard!)] as! [UIViewController]
        self.pageViewController!.setViewControllers(viewControllers , direction: .forward,
                                                    animated: true, completion: {done in })
        updateNavigationButtonState()
    }

    @IBAction func onBackPress(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
