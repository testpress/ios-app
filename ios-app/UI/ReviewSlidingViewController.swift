//
//  ReviewSlidingViewController.swift
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

class ReviewSlidingViewController: BaseQuestionsSlidingViewController {
    
    @IBOutlet weak var languagefilter: UIBarButtonItem!
    
    var reviewSolutionViewController: ReviewSolutionsViewController? = nil
    var reviewQuestionListViewController: ReviewQuestionListViewController? = nil
    
    override func awakeFromNib() {
        reviewSolutionViewController = storyboard?.instantiateViewController(withIdentifier:
            Constants.REVIEW_SOLUTIONS_VIEW_CONTROLLER) as? ReviewSolutionsViewController
        
        self.mainViewController = reviewSolutionViewController
        slidingMenuDelegate = reviewSolutionViewController
        reviewQuestionListViewController = storyboard?.instantiateViewController(withIdentifier:
            Constants.REVIEW_QUESTION_LIST_VIEW_CONTROLLER) as? ReviewQuestionListViewController
        
        self.leftViewController = reviewQuestionListViewController
        super.awakeFromNib()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showOrHideLanguageIcon()
    }
    
    func showOrHideLanguageIcon(){
        if (self.exam?.hasMultipleLanguages() ?? false) {
            languagefilter.isEnabled = true
            languagefilter.tintColor = nil
        } else {
            languagefilter.isEnabled = false
            languagefilter.tintColor = UIColor.clear
        }
    }
    
    @IBAction func languageFiterButton(_ sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: "Select Language", message: nil, preferredStyle: .actionSheet)

        let languageOptions = self.getLanguageOptions()
        languageOptions.forEach { actionSheet.addAction($0) }

        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = sender.plainView
            popoverController.permittedArrowDirections = [.up, .down]
        }

        present(actionSheet, animated: true, completion: nil)
    }
    
    private func getLanguageOptions() -> [UIAlertAction] {
        if let exam = self.exam {
            return exam.languages.map { language in
                let action = UIAlertAction(title: language.title, style: .default) { _ in
                    self.updateLanguage(language)
                }
                if language.code == self.exam?.selectedLanguage?.code {
                    let checkmarkImage = UIImage(named: "testpress_check_mark")
                    action.setValue(checkmarkImage, forKey: "image")
                }
                return action
            } + [UIAlertAction(title: "Cancel", style: .cancel, handler: nil)]
        }
        return [UIAlertAction(title: "Cancel", style: .cancel, handler: nil)]
    }
    
    func updateLanguage(_ language: Language) {
        if self.exam?.selectedLanguage?.code == language.code {
            return
        }
        setSelectedLanguage(language)
        reviewSolutionViewController?.baseQuestionsDataSource.setLanguage(language)
        reviewQuestionListViewController?.setLanguage(language)
        reviewSolutionViewController?.setCurrentQuestion(index: reviewSolutionViewController?.getCurrentIndex() ?? 0)
    }

    private func setSelectedLanguage(_ language: Language) {
        DBManager<Exam>().write {
            self.exam?.selectedLanguage = language
        }
    }
}
