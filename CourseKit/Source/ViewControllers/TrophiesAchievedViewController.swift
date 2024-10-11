//
//  TrophiesAchievedViewController.swift
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

class TrophiesAchievedViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var trophiesCountSign: UILabel!
    @IBOutlet weak var trophiesCount: UILabel!
    @IBOutlet weak var okayButton: UIButton!
    @IBOutlet weak var trophyImageLayout: UIView!
    
    var exam: Exam?
    var contentAttempt: ContentAttempt!
    
    override func viewDidLoad() {
        UIUtils.setButtonDropShadow(okayButton)
        trophyImageLayout.layer.borderColor = Colors.getRGB(Colors.GRAY_LIGHT).cgColor
        let trophies = String.getValue(contentAttempt.trophies!)
        let startIndex = trophies.index(trophies.startIndex, offsetBy: 1)
        if trophies.elementsEqual("NA") {
            trophiesCount.text = "0"
            trophiesCountSign.isHidden = true
        } else if trophies.contains("+") {
            trophiesCount.text = String(trophies[startIndex...])
            trophiesCountSign.text = "+"
        } else if trophies.contains("-") {
            trophiesCount.text = String(trophies[startIndex...])
            trophiesCountSign.text = "-"
        } else {
            trophiesCount.text = trophies
            trophiesCountSign.isHidden = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        // Set scroll view content height to support the scroll
        let height = contentStackView.frame.size.height
        contentViewHeightConstraint.constant = height
        scrollView.contentSize.height = height
        contentView.layoutIfNeeded()
    }
    
    @IBAction func onClickOkay(_ sender: UIButton) {
        let viewController = storyboard?.instantiateViewController(withIdentifier:
            Constants.TEST_REPORT_VIEW_CONTROLLER) as! TestReportViewController
        
        viewController.exam = exam
        viewController.attempt = contentAttempt.assessment
        present(viewController, animated: true, completion: nil)
    }
}
