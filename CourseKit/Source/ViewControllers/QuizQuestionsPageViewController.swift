//
//  QuizQuestionsPageViewController.swift
//  ios-app
//
//  Created by Karthik on 18/05/20.
//  Copyright © 2020 Testpress. All rights reserved.
//

import UIKit
import CourseKit

class QuizQuestionsPageViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    var currentIndex: Int!
    var attemptItems: [AttemptItem]!
    var exam: Exam?
    var attempt: Attempt?
    var contentAttempt: ContentAttempt?
    var viewModel: QuizQuestionsViewModel!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var buttonLayout: UIView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var bottomShadowView: UIView!
    
    let loadingDialogController = UIUtils.initProgressDialog(message: Strings.ENDING_EXAM)
    var pageViewController: UIPageViewController!
    
    override func viewDidLoad() {
        if exam == nil {
            viewModel = QuizQuestionsViewModel(attempt: attempt)
        } else {
            viewModel = QuizQuestionsViewModel(contentAttempt: contentAttempt)
        }
        submitButton.addTextSpacing(spacing: 1.0)
        currentIndex = viewModel.getFirstUnAttemptedItemIndex()
        initializePageViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if pageViewController.viewControllers?.count == 0 {
            setFirstViewController()
        }
    }
    
    func initializePageViewController() {
        pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                  navigationOrientation: .horizontal,
                                                  options: nil)
        pageViewController.delegate = self
        self.add(pageViewController)
        pageViewController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        pageViewController.view.frame = CGRect(x:0, y:0, width: self.view.frame.width, height: self.view.frame.height - buttonLayout.frame.height)
    }
    
    func setFirstViewController() {
        let viewController = getQuestionViewController(index: currentIndex)
        pageViewController.setViewControllers(
            [viewController],
            direction: .forward,
            animated: false
        )
    }
    
    func getQuestionViewController(index: Int = 0) -> QuizQuestionViewController {
        let viewController = QuizQuestionViewController()
        viewController.attemptItem = self.attemptItems[index]
        return viewController
    }
    
    func showQuestion(index: Int) {
        if (attemptItems.count <= index) {
            return
        }
        
        let viewController = getQuestionViewController(index: index)
        let direction: UIPageViewController.NavigationDirection =
            index > currentIndex ? .forward : .reverse
        pageViewController.setViewControllers([viewController] , direction: direction,
                                              animated: true, completion: nil)
        currentIndex += 1
    }
    
    func getReviewController() -> QuizReviewViewController {
        let viewController = QuizReviewViewController()
        viewController.attemptItem = viewModel.getAttemptItem(id: self.attemptItems[currentIndex].id)
        return viewController
    }
    
    func endExam() {
        present(loadingDialogController, animated: false)
        if exam != nil {
            viewModel.endExam { contentAttempt, error in
                self.loadingDialogController.dismiss(animated: false, completion: nil)
                self.gotoTestReport(contentAttempt: contentAttempt!, attempt: nil)
            }
        } else {
            viewModel.endAttempt { attempt, error in
                self.loadingDialogController.dismiss(animated: false, completion: nil)
                self.gotoTestReport(contentAttempt: nil, attempt: attempt!)
            }
        }
    }
    
    func gotoTestReport(contentAttempt: ContentAttempt?, attempt: Attempt?) {
        let storyboard = UIStoryboard(name: Constants.EXAM_REVIEW_STORYBOARD, bundle: nil)
        if contentAttempt != nil {
            let viewController = storyboard.instantiateViewController(withIdentifier:
                Constants.TROPHIES_ACHIEVED_VIEW_CONTROLLER) as! TrophiesAchievedViewController
            
            viewController.exam = exam
            viewController.contentAttempt = contentAttempt
            present(viewController, animated: true, completion: nil)
        } else {
            let viewController = storyboard.instantiateViewController(withIdentifier:
                Constants.TEST_REPORT_VIEW_CONTROLLER) as! TestReportViewController
            
            viewController.exam = exam
            viewController.attempt = attempt
            present(viewController, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func onNextClick(_ sender: Any) {
        if (pageViewController.viewControllers?.first is QuizQuestionViewController) {
            showReview()
        } else {
            if (attemptItems.count == currentIndex + 1) {
                endExam()
                return
            }

            submitButton.setTitle("CHECK", for: .normal)
            showQuestion(index: currentIndex + 1)
        }
    }
    
    func showReview() {
        submitButton.setTitle("CONTINUE", for: .normal)
        viewModel.submitAnswer(id: attemptItems![currentIndex].id)
        pageViewController.setViewControllers([getReviewController()] , direction: .forward,
                                              animated: false, completion: nil)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return getQuestionViewController(index: currentIndex - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return getQuestionViewController(index: currentIndex + 1)
    }
    
    override func viewDidLayoutSubviews() {
        // Set frames of the view here to support both portrait & landscape view
        // Add gradient shadow layer to the shadow container view
        let bottomGradient = CAGradientLayer()
        bottomGradient.frame = bottomShadowView.bounds
        bottomGradient.colors = [UIColor.white.cgColor, UIColor.black.cgColor]
        bottomShadowView.layer.insertSublayer(bottomGradient, at: 0)
    }
}
