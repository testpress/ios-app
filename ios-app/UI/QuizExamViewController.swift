//
//  QuizExamViewController.swift
//  ios-app
//
//  Created by Karthik on 12/05/20.
//  Copyright © 2020 Testpress. All rights reserved.
//

import UIKit

class QuizExamViewController: UIViewController {
    var contentAttempt: ContentAttempt!
    var exam: Exam!
    let attemptRepository = AttemptRepository()
    let loadingViewController = LoadingViewController()

    @IBOutlet weak var containerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStatusBarColor()
        loadQuestions()
    }
    
    func loadQuestions() {
        showLoadingScreen()
        attemptRepository.loadQuestions(url: exam.getQuestionsURL(), examId: exam.id, attemptId: contentAttempt.assessment.id, completion: {
            attemptItems, error in
            self.loadingViewController.remove()
            if let error = error {
                print("Error Occurred : \(error)")
                return
            }
            
            let storyboard = UIStoryboard(name: Constants.TEST_ENGINE, bundle: nil)
            let questionExamViewController = storyboard.instantiateViewController(withIdentifier:
                Constants.QUIZ_QUESTIONS_PAGE_VIEW_CONTROLLER) as! QuizQuestionsPageViewController
            
            questionExamViewController.attemptItems = attemptItems
            questionExamViewController.contentAttempt = self.contentAttempt
            questionExamViewController.exam = self.exam
            questionExamViewController.currentIndex = 0
            self.add(questionExamViewController)
            questionExamViewController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            
            questionExamViewController.view.frame = CGRect(x:0, y:self.containerView.frame.origin.y + 20, width: self.view.frame.width, height: self.view.frame.height - (self.containerView.frame.origin.y + 20))
        })
    }
    
    func showLoadingScreen() {
        add(loadingViewController)
        loadingViewController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        loadingViewController.view.frame = self.containerView.frame
    }
    
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
