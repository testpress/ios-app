//
//  BaseQuestionsSlidingViewController.swift
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
import SlideMenuController

protocol SlidingMenuDelegate {
    func dismissViewController()
}

protocol QuestionsSlidingMenuDelegate {
    func displayQuestions(currentQuestionIndex: Int)
    func updateQuestions(_ attemptItems: [AttemptItem], _ language: Language?)
}

class BaseQuestionsSlidingViewController: SlideMenuController {
    
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    
    var exam: Exam?
    var attempt: Attempt!
    var courseContent: Content!
    var contentAttempt: ContentAttempt!
    var slidingMenuDelegate: SlidingMenuDelegate!
    var questionsSlidingMenuDelegate: QuestionsSlidingMenuDelegate!
    var panelOpened: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
        }
    }
    
    override func awakeFromNib() {
        let mainViewController = self.mainViewController as! BaseQuestionsPageViewController
        let leftViewController = self.leftViewController as! BaseQuestionsListViewController
        
        leftViewController.delegate = mainViewController
        questionsSlidingMenuDelegate = leftViewController
        delegate = self
        SlideMenuOptions.contentViewScale = 1.0
        SlideMenuOptions.hideStatusBar = false
        SlideMenuOptions.panGesturesEnabled = false
        SlideMenuOptions.leftViewWidth = self.view.frame.size.width
        super.awakeFromNib()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let questionsPageViewController = mainViewController as! BaseQuestionsPageViewController
        questionsPageViewController.attempt = attempt
        questionsPageViewController.exam = exam
        questionsPageViewController.courseContent = courseContent
        questionsPageViewController.contentAttempt = contentAttempt
        questionsPageViewController.parentviewController = self
    }
    
    @IBAction func onPressBackButton() {
        if panelOpened {
            slideMenuController()?.closeLeft()
        } else {
            slidingMenuDelegate.dismissViewController()
        }
    }
    
    func showQuestionList() {
        panelOpened = true
        let questionsPageViewController = mainViewController as! BaseQuestionsPageViewController
        questionsSlidingMenuDelegate.displayQuestions(
            currentQuestionIndex: questionsPageViewController.getCurrentIndex())
    }
    
}

extension BaseQuestionsSlidingViewController: SlideMenuControllerDelegate {
    
    func leftWillOpen() {
        showQuestionList()
    }
    
    func leftDidOpen() {
        if !panelOpened {
            showQuestionList()
        }
    }
    
    func leftDidClose() {
        panelOpened = false
    }
}
