//
//  TestReportViewController.swift
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

class TestReportViewController: UIViewController {

    @IBOutlet weak var schollershipImageContainer: UIView!
    @IBOutlet weak var correctImageContainer: UIView!
    @IBOutlet weak var incorrectImageContainer: UIView!
    @IBOutlet weak var clockImageContainer: UIView!
    @IBOutlet weak var accurateImageContainer: UIView!
    @IBOutlet weak var rankLayout: UIStackView!
    @IBOutlet weak var examTitle: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var rank: UILabel!
    @IBOutlet weak var maxRank: UILabel!
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var correct: UILabel!
    @IBOutlet weak var incorrect: UILabel!
    @IBOutlet weak var timeTaken: UILabel!
    @IBOutlet weak var accuracy: UILabel!
    @IBOutlet weak var contentView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bottomShadowView: UIView!
    @IBOutlet weak var solutionsButton: UIButton!
    
    var attempt: Attempt?
    var exam: Exam?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        schollershipImageContainer.layer.borderColor = Colors.getRGB(Colors.GRAY_LIGHT).cgColor
        correctImageContainer.layer.borderColor = Colors.getRGB(Colors.GRAY_LIGHT).cgColor
        incorrectImageContainer.layer.borderColor = Colors.getRGB(Colors.GRAY_LIGHT).cgColor
        clockImageContainer.layer.borderColor = Colors.getRGB(Colors.GRAY_LIGHT).cgColor
        accurateImageContainer.layer.borderColor = Colors.getRGB(Colors.GRAY_LIGHT).cgColor
        
        examTitle.text = exam!.title!
        date.text = FormatDate.format(dateString: attempt!.date!,
                                      givenFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
        
        if !(attempt!.rankEnabled!) || String(describing: attempt!.rank!) == "NA" {
            rankLayout.isHidden = true
        } else {
            rank.text = String(describing: attempt!.rank!)
            maxRank.text = String(describing: attempt!.maxRank!)
        }
        score.text = attempt!.score!
        correct.text = String(attempt!.correctCount!)
        incorrect.text = String(attempt!.incorrectCount!)
        timeTaken.text = attempt!.timeTaken ?? "NA"
        accuracy.text = String(attempt!.accuracy!) + "%"
        UIUtils.setButtonDropShadow(solutionsButton)
    }

    @IBAction func showSolutions(_ sender: UIButton) {
        let slideMenuController = self.storyboard?.instantiateViewController(withIdentifier:
            Constants.REVIEW_NAVIGATION_VIEW_CONTROLLER) as! UINavigationController
        
        let viewController =
            slideMenuController.viewControllers.first as! ReviewSlidingViewController
        
        viewController.exam = exam
        viewController.attempt = attempt
        self.present(slideMenuController, animated: true, completion: nil)
    }
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        let presentingViewController =
            self.presentingViewController?.presentingViewController?.presentingViewController
        
        if presentingViewController is UITabBarController {
            let tabViewController =
                presentingViewController?.childViewControllers[0] as! ExamsTabViewController
            
            tabViewController.dismiss(animated: false, completion: {
                if tabViewController.currentIndex != 2 {
                    // Move to histroy tab
                    tabViewController.moveToViewController(at: 2, animated: true)
                }
                // Refresh the items
                tabViewController.reloadPagerTabStripView()
            })
        } else if presentingViewController is AttemptsListViewController {
            let attemptsListViewController = presentingViewController as! AttemptsListViewController
            attemptsListViewController.dismiss(animated: false, completion: {
                // Remove exsiting items
                attemptsListViewController.attempts.removeAll()
                // Load new attempts list with progress
                attemptsListViewController.loadAttemptsWithProgress(url: self.exam!.attemptsUrl!)
            })
        } else if presentingViewController is ContentDetailPageViewController {
            
            let contentDetailPageViewController =
                presentingViewController as! ContentDetailPageViewController
            
            contentDetailPageViewController.dismiss(animated: false, completion: {
                contentDetailPageViewController.updateCurrentExamContent()
            })
        } else if self.presentingViewController?.presentingViewController! is
            ContentDetailPageViewController {
            
            let contentDetailPageViewController  =
                self.presentingViewController?.presentingViewController!
                    as! ContentDetailPageViewController
            
            contentDetailPageViewController.dismiss(animated: false, completion: {
                contentDetailPageViewController.updateCurrentExamContent()
            })
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    // Set frames of the views in this method to support both portrait & landscape view
    override func viewDidLayoutSubviews() {
        // Add gradient shadow layer to the shadow container view
        let bottomGradient = CAGradientLayer()
        bottomGradient.frame = bottomShadowView.bounds
        bottomGradient.colors = [UIColor.white.cgColor, UIColor.black.cgColor]
        bottomShadowView.layer.addSublayer(bottomGradient)
        
        // Set scroll view content height to support the scroll
        scrollView.contentSize.height = contentView.frame.size.height
    }

}
