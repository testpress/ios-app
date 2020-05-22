//
//  StartQuizExamViewController.swift
//  ios-app
//
//  Created by Karthik on 12/05/20.
//  Copyright © 2020 Testpress. All rights reserved.
//

import UIKit

class StartQuizExamViewController: UIViewController {
    @IBOutlet weak var examTitle: UILabel!
    @IBOutlet weak var questionsCount: UILabel!
    @IBOutlet weak var startEndDate: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var examInfoLabel: UILabel!
    @IBOutlet weak var bottomShadowView: UIView!
    @IBOutlet weak var startButtonLayout: UIView!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIStackView!

    var content: Content!
    var exam: Exam!
    var viewModel: QuizExamViewModel!
    var emptyView: EmptyView!
    let alertController = UIUtils.initProgressDialog(message: "Please wait\n\n")

    override func viewDidLoad() {
        exam = content.exam
        viewModel = QuizExamViewModel(exam: exam)
        bindData()
        UIUtils.setButtonDropShadow(startButton)
    }
    
    func bindData() {
        examTitle.text = viewModel.title
        questionsCount.text = viewModel.noOfQuestions
        startEndDate.text = viewModel.startEndDate
        descriptionLabel.text = viewModel.description
          
        if viewModel.description.isEmpty {
            descriptionLabel.isHidden = true
        }
        startButtonLayout.isHidden = !viewModel.canStartExam && content.isLocked
        examInfoLabel.text = viewModel.examInfo
        
        if content != nil && content.isLocked {
            examInfoLabel.text = Strings.SCORE_GOOD_IN_PREVIOUS
            startButtonLayout.isHidden = true
        }
        
        if (examInfoLabel.text?.isEmpty == true) {
            examInfoLabel.isHidden = true
        }
    }
    
    @IBAction func startExam(_ sender: UIButton) {
//        present(alertController, animated: false, completion: nil)
//        startButton.isHidden = true
//        startAttempt()
        present(alertController, animated: false, completion: nil)

        let repository = AttemptRepository()
        repository.loadAttempt(attemptsUrl: content.getAttemptsUrl(), completion: {
            contentAttempt, error in
            if let error = error {
                var retryButtonText: String?
                var retryHandler: (() -> Void)?
                if error.kind == .network {
                    retryButtonText = Strings.TRY_AGAIN
                    retryHandler = {
                        self.present(self.alertController, animated: false, completion: nil)
                        self.startExam(sender)
                    }
                }
                let (image, title, description) = error.getDisplayInfo()
                self.emptyView.show(image: image, title: title, description: description, retryButtonText: retryButtonText,  retryHandler: retryHandler)
                
                self.alertController.dismiss(animated: true, completion: nil)
                return
            }
            
            self.alertController.dismiss(animated: true, completion: nil)
            self.content.attemptsCount += 1
            self.loadQuestions(contentAttempt: contentAttempt!)
        })
    }
    
    func loadQuestions(contentAttempt: ContentAttempt) {
        let storyboard = UIStoryboard(name: Constants.TEST_ENGINE, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier:
              Constants.QUIZ_EXAM_VIEW_CONTROLLER) as! QuizExamViewController

          viewController.contentAttempt = contentAttempt
        viewController.exam = self.exam
          present(viewController, animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        // Add gradient shadow layer to the shadow container view
        if bottomShadowView != nil {
            let bottomGradient = CAGradientLayer()
            bottomGradient.frame = bottomShadowView.bounds
            bottomGradient.colors = [UIColor.white.cgColor, UIColor.black.cgColor]
            bottomShadowView.layer.insertSublayer(bottomGradient, at: 0)
        }
        
        // Set scroll view content height to support the scroll
        scrollView.contentSize.height = contentView.frame.size.height
    }
}

