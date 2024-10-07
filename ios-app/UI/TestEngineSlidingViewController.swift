//
//  TestEngineSlidingViewController.swift
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

class TestEngineSlidingViewController: BaseQuestionsSlidingViewController {
    
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var pauseButtonLayout: UIStackView!
    @IBOutlet weak var languagefilter: UIButton!
    var questionListViewController: QuestionListViewController? = nil
    
    override func awakeFromNib() {
        let mainViewController = storyboard?.instantiateViewController(
            withIdentifier: Constants.TEST_ENGINE_VIEW_CONTROLLER) as! TestEngineViewController
        
        self.mainViewController = mainViewController
        slidingMenuDelegate = mainViewController
        mainViewController.parentSlidingViewController = self
        questionListViewController = storyboard?.instantiateViewController(
            withIdentifier: Constants.QUESTION_LIST_VIEW_CONTROLLER) as? QuestionListViewController
        
        self.leftViewController = questionListViewController
        super.awakeFromNib()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarItem.rightBarButtonItems = [UIBarButtonItem(customView: languagefilter), UIBarButtonItem(customView: pauseButtonLayout)]
        showOrHideLanguageButton()
    }
    
    override func leftDidClose() {
        super.leftDidClose()
        navigationBarItem.leftBarButtonItem?.image = Images.CloseButton.image
    }
    
    override func showQuestionList() {
        super.showQuestionList()
        navigationBarItem.leftBarButtonItem?.image = Images.BackButton.image
    }
    
    func showOrHideLanguageButton() {
        languagefilter.isHidden = !(self.exam?.hasMultipleLanguages() ?? false)
    }
}
