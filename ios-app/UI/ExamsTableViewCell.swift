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

class ExamsTableViewCell: UITableViewCell {

    @IBOutlet weak var examName: UILabel!
    @IBOutlet weak var examViewCell: UIView!
    
    var parentViewController: UIViewController? = nil
    var exam: Exam?
    var examState: ExamState?
    
    func setExam(_ exam: Exam, examState: ExamState, viewController: UIViewController){
        parentViewController = viewController
        self.exam = exam
        self.examState = examState
        examName.text = exam.title
        
        if examState == ExamState.available {
            let tapRecognizer = UITapGestureRecognizer(target: self,
                                                       action: #selector(self.showStartExamScreen))
            
            examViewCell.addGestureRecognizer(tapRecognizer)
        } else if examState == ExamState.history {
            let tapRecognizer = UITapGestureRecognizer(target: self,
                                                       action: #selector(self.showAttemptsList))
            
            examViewCell.addGestureRecognizer(tapRecognizer)
        }
    }
    
    func showStartExamScreen() {
        let storyboard = UIStoryboard(name: Constants.TEST_ENGINE, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier:
            Constants.START_EXAM_SCREEN_VIEW_CONTROLLER) as! StartExamScreenViewController
        viewController.exam = self.exam!
        parentViewController?.showDetailViewController(viewController, sender: self)
    }
    
    func showAttemptsList() {
        let storyboard = UIStoryboard(name: Constants.TEST_ENGINE, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier:
            Constants.ATTEMPTS_VIEW_CONTROLLER) as! AttemptsListViewController
        viewController.exam = exam!
        parentViewController?.showDetailViewController(viewController, sender: self)
    }
    
}
