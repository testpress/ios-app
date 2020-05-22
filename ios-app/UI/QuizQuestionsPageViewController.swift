//
//  QuizQuestionsPageViewController.swift
//  ios-app
//
//  Created by Karthik on 18/05/20.
//  Copyright © 2020 Testpress. All rights reserved.
//

import UIKit

class QuizQuestionsPageViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    var currentIndex: Int!
    var attemptItems: [AttemptItem]!
    var exam: Exam!
    var contentAttempt: ContentAttempt!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var buttonLayout: UIView!
    
    let loadingDialogController = UIUtils.initProgressDialog(message: Strings.ENDING_EXAM)
    var pageViewController: UIPageViewController!
    
    override func viewDidLoad() {
        pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                  navigationOrientation: .horizontal,
                                                  options: nil)
        pageViewController.delegate = self
        self.add(pageViewController)
        pageViewController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        pageViewController.view.frame = CGRect(x:0, y:0, width: self.view.frame.width, height: self.view.frame.height - buttonLayout.frame.height)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("Attempt Items : \(self.attemptItems)")

        if pageViewController.viewControllers?.count == 0 {
            setFirstViewController()
        }
    }
    
    func setFirstViewController() {
        let viewController = getQuestionController()
        pageViewController.setViewControllers(
            [viewController],
            direction: .forward,
            animated: false
        )
    }
    
    func getQuestionController(index: Int = 0) -> QuizQuestionViewController {
        let viewController = QuizQuestionViewController()
        viewController.attemptItem = self.attemptItems[index]
        return viewController
    }
    
    func setCurrentQuestion(index: Int) {
        if (attemptItems.count <= index) {
            return
        }
        let viewController = getQuestionController(index: index)
        let direction: UIPageViewController.NavigationDirection =
            index > currentIndex ? .forward : .reverse
        
        pageViewController.setViewControllers([viewController] , direction: direction,
                                              animated: true, completion: nil)
        currentIndex += 1
    }
    
    func getReviewController() -> QuizReviewViewController {
        let attemptItemRepository = AttemptItemRepository()
        let viewController = QuizReviewViewController()
        viewController.attemptItem = attemptItemRepository.getAttemptItem(id: self.attemptItems[currentIndex].id)
        return viewController
    }
    
    func endExam() {
        present(loadingDialogController, animated: false)
        let attemptRepository = AttemptRepository()
        attemptRepository.endExam(url: contentAttempt.getEndAttemptUrl(), completion: { contentAttempt, error in
            self.loadingDialogController.dismiss(animated: false, completion: nil)
            self.gotoTestReport(contentAttempt: contentAttempt!)
        })
    }
    
    func gotoTestReport(contentAttempt: ContentAttempt) {
        let storyboard = UIStoryboard(name: Constants.EXAM_REVIEW_STORYBOARD, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier:
            Constants.TROPHIES_ACHIEVED_VIEW_CONTROLLER) as! TrophiesAchievedViewController
        
        viewController.exam = exam
        viewController.contentAttempt = contentAttempt
        present(viewController, animated: true, completion: nil)
    }
    
    
    @IBAction func onNextClick(_ sender: Any) {
        if (attemptItems.count == currentIndex + 1) {
            endExam()
            return
        }
        
        if (pageViewController.viewControllers?.first is QuizQuestionViewController) {
            let attemptItemRepository = AttemptItemRepository()
            attemptItemRepository.submitAnswer(id: attemptItems![currentIndex].id)
            pageViewController.setViewControllers([getReviewController()] , direction: .forward,
            animated: false, completion: nil)
        } else {
            setCurrentQuestion(index: currentIndex + 1)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return getQuestionController(index: currentIndex - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return getQuestionController(index: currentIndex + 1)
    }
    
}

