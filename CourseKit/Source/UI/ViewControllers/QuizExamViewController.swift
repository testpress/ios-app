//
//  QuizExamViewController.swift
//  ios-app
//
//  Created by Karthik on 12/05/20.
//  Copyright © 2020 Testpress. All rights reserved.
//

import UIKit

class QuizExamViewController: BaseUIViewController {
    var contentAttempt: ContentAttempt?
    var exam: Exam?
    var attempt: Attempt?
    let attemptRepository = AttemptRepository()
    let loadingViewController = LoadingViewController()
    var questionsPageViewController: QuizQuestionsPageViewController!
    var emptyView: EmptyView!
    var viewModel: QuizExamViewModelDelegate!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if exam != nil {
            viewModel = QuizExamViewModel(exam: exam!)
        } else {
            viewModel = CustomTestQuizExamViewModel()
        }
        self.setStatusBarColor()
        initializeQuizQuestionsPageViewController()
        loadQuestions()
    }
    
    func initializeQuizQuestionsPageViewController() {
        let storyboard = UIStoryboard(name: Constants.TEST_ENGINE, bundle: TestpressCourse.bundle)
        questionsPageViewController = storyboard.instantiateViewController(withIdentifier:
            Constants.QUIZ_QUESTIONS_PAGE_VIEW_CONTROLLER) as? QuizQuestionsPageViewController
        initializeEmptyView()
    }
    
    func initializeEmptyView() {
        emptyView = EmptyView.getInstance(parentView: view)
        emptyView.frame = view.frame
    }
    
    func loadQuestions() {
        showLoadingScreen()
        let attemptId = (exam != nil) ? contentAttempt?.assessment.id ?? 0 : attempt?.id ?? 0
        viewModel.loadQuestions(attemptId: attemptId) {attemptItems,error in
            self.loadingViewController.remove()
            if let error = error {
                self.showErrorView(error: error)
                return
            }
            
            self.showQuestionsPageView(attemptItems: attemptItems ?? [])
        }
    }
    
    func showQuestionsPageView(attemptItems: [AttemptItem]){
        self.navigationBarItem.title = self.exam?.title ?? "Custom Module"
        self.questionsPageViewController.attemptItems = attemptItems
        self.questionsPageViewController.contentAttempt = self.contentAttempt
        self.questionsPageViewController.exam = self.exam
        self.questionsPageViewController.attempt = self.attempt
        self.add(self.questionsPageViewController)
        self.questionsPageViewController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.questionsPageViewController.view.frame = CGRect(x:0, y:self.containerView.frame.origin.y + self.navigationBar.frame.height, width: self.view.frame.width, height: self.view.frame.height - (self.containerView.frame.origin.y + self.navigationBar.frame.height))
    }
    
    func showErrorView(error: TPError) {
        var retryButtonText: String?
        var retryHandler: (() -> Void)?
        if error.kind == .network {
            retryButtonText = Strings.TRY_AGAIN
            retryHandler = {
                self.loadQuestions()
            }
        }
        let (image, title, description) = error.getDisplayInfo()
        self.emptyView.show(image: image, title: title, description: description, retryButtonText: retryButtonText,  retryHandler: retryHandler)
    }
    
    func showLoadingScreen() {
        add(loadingViewController)
        loadingViewController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        loadingViewController.view.frame = self.containerView.frame
    }
    
    
    @IBAction func endExam(_ sender: Any) {
        UIUtils.showSimpleAlert(
            title: Strings.ARE_YOU_SURE,
            message: "Do you wish to end the exam ?",
            viewController: questionsPageViewController,
            positiveButtonText: Strings.YES,
            positiveButtonStyle: .destructive,
            negativeButtonText: Strings.NO,
            cancelable: true,
            cancelHandler: #selector(self.closeAlert),
            completion: { action in
                self.endExam()
                self.dismiss(animated: true, completion: nil)
        })
    }
    
    func endExam() {
        let loadingDialogController = UIUtils.initProgressDialog(message: Strings.ENDING_EXAM)
        present(loadingDialogController, animated: false)
        let attemptRepository = AttemptRepository()
        if exam != nil {
            attemptRepository.endExam(url: contentAttempt!.getEndAttemptUrl(), completion: { contentAttempt, error in
                loadingDialogController.dismiss(animated: false, completion: nil)
                self.dismiss(animated: true, completion: nil)
            })
        } else {
            attemptRepository.endAttempt(url: attempt!.getEndAttemptUrl(), completion: { attempt, error in
                loadingDialogController.dismiss(animated: false, completion: nil)
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    @objc func closeAlert(gesture: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
}
