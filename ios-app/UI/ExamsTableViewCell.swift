//
//  ExamsTableViewCell.swift
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
import CourseKit

class ExamsTableViewCell: UITableViewCell {

    @IBOutlet weak var examName: UILabel!
    @IBOutlet weak var examViewCell: UIView!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var noOfQuestions: UILabel!
    
    var parentViewController: UIViewController? = nil
    var exam: Exam?
    var examState: ExamState?
    var accessCode: String!
    
    func initExamCell(_ exam: Exam, examState: ExamState, viewController: UIViewController){
        initCell(exam, viewController: viewController)
        self.examState = examState
        
        var actionHandler: Selector
        if examState == ExamState.history {
            actionHandler = #selector(self.showAttemptsList)
        } else {
            actionHandler = #selector(self.showStartExamScreen)
        }
        let tapRecognizer = UITapGestureRecognizer(target: self, action: actionHandler)
        examViewCell.addGestureRecognizer(tapRecognizer)
    }
    
    func initExamCell(_ exam: Exam, accessCode: String, viewController: UIViewController) {
        self.accessCode = accessCode
        initCell(exam, viewController: viewController)
        
        var actionHandler: Selector
        if exam.attemptsCount != 0 {
            actionHandler = #selector(self.showAttemptsList)
        } else {
            actionHandler = #selector(self.showStartExamScreen)
        }
        let tapRecognizer = UITapGestureRecognizer(target: self, action: actionHandler)
        examViewCell.addGestureRecognizer(tapRecognizer)
    }
    
    func initCell(_ exam: Exam, viewController: UIViewController) {
        parentViewController = viewController
        self.exam = exam
        examName.text = exam.title
        duration.text = exam.duration
        noOfQuestions.text = String(exam.numberOfQuestions)
    }
    
    @objc func showStartExamScreen() {
        let storyboard = UIStoryboard(name: Constants.TEST_ENGINE, bundle: TestpressCourse.bundle)
        let viewController = storyboard.instantiateViewController(withIdentifier:
            Constants.START_EXAM_SCREEN_VIEW_CONTROLLER) as! StartExamScreenViewController
        viewController.exam = self.exam!
        viewController.accessCode = accessCode
        parentViewController?.showDetailViewController(viewController, sender: self)
    }
    
    @objc func showAttemptsList() {
        let storyboard = UIStoryboard(name: Constants.TEST_ENGINE, bundle: TestpressCourse.bundle)
        let viewController = storyboard.instantiateViewController(withIdentifier:
            Constants.ATTEMPTS_VIEW_CONTROLLER) as! AttemptsListViewController
        viewController.exam = exam!
        viewController.accessCode = accessCode
        parentViewController?.showDetailViewController(viewController, sender: self)
    }
    
}
