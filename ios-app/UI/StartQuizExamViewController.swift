//
//  StartQuizExamViewController.swift
//  ios-app
//
//  Created by Karthik on 12/05/20.
//  Copyright © 2020 Testpress. All rights reserved.
//

import UIKit
import RealmSwift

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
    @IBOutlet weak var containerView: UIView!
    
    var content: Content!
    var exam: Exam!
    var viewModel: QuizExamViewModel!
    var emptyView: EmptyView!
    let alertController = UIUtils.initProgressDialog(message: "Please wait\n\n")
    
    override func viewDidLoad() {
        viewModel = QuizExamViewModel(content: content)
        bindData()
        UIUtils.setButtonDropShadow(startButton)
        addContentAttemptListViewController()
        initializeEmptyView()
    }
    
    func initializeEmptyView() {
        emptyView = EmptyView.getInstance(parentView: view)
        emptyView.frame = view.frame
    }
    
    func addContentAttemptListViewController() {
        let storyboard = UIStoryboard(name: Constants.CHAPTER_CONTENT_STORYBOARD, bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: Constants.CONTENT_EXAM_ATTEMPS_TABLE_VIEW_CONTROLLER
            ) as! ContentExamAttemptsTableViewController
        
        viewController.content = content
        add(viewController)
        viewController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        viewController.view.frame = self.containerView.frame
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
        present(alertController, animated: false, completion: nil)
        viewModel.loadAttempt { contentAttempt, error in
            self.alertController.dismiss(animated: true, completion: nil)
            
            if let error = error {
                var retryButtonText: String?
                var retryHandler: (() -> Void)?
                if error.kind == .network {
                    retryButtonText = Strings.TRY_AGAIN
                    retryHandler = {
                        self.startExam(sender)
                    }
                }
                let (image, title, description) = error.getDisplayInfo()
                self.emptyView.show(image: image, title: title, description: description, retryButtonText: retryButtonText,  retryHandler: retryHandler)
                
                return
            }
            
            try! Realm().write {
                self.content.attemptsCount += 1
            }
        }
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

