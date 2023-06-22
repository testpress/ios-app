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
import RealmSwift

class TestReportViewController: UIViewController {

    @IBOutlet weak var rankLayout: UIView!
    @IBOutlet weak var examTitle: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var rank: UILabel!
    @IBOutlet weak var maxRank: UILabel!
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var scoreLayout: UIView!
    @IBOutlet weak var totalQuestions: UILabel!
    @IBOutlet weak var totalMarks: UILabel!
    @IBOutlet weak var totalTime: UILabel!
    @IBOutlet weak var cutoff: UILabel!
    @IBOutlet weak var percentile: UILabel!
    @IBOutlet weak var percentileLayout: UIView!
    @IBOutlet weak var percentage: UILabel!
    @IBOutlet weak var correct: UILabel!
    @IBOutlet weak var incorrect: UILabel!
    @IBOutlet weak var timeTaken: UILabel!
    @IBOutlet weak var accuracy: UILabel!
    @IBOutlet weak var contentView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bottomShadowView: UIView!
    @IBOutlet weak var solutionsButton: UIButton!
    @IBOutlet weak var analyticsButton: UIButton!
    @IBOutlet weak var timeAnalyticsButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var solutionButtonLayout: UIStackView!
    @IBOutlet weak var analyticsButtonLayout: UIStackView!
    @IBOutlet weak var shareButtonLayout: UIStackView!
    
    var attempt: Attempt!
    var exam: Exam!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStatusBarColor()

        
        examTitle.text = exam!.title
        date.text = FormatDate.format(dateString: attempt!.date!,
                                      givenFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
        
        if !(attempt!.rankEnabled) || String.getValue(attempt!.rank) == "NA" {
            rankLayout.isHidden = true
        } else {
            rank.text = String.getValue(attempt!.rank)
            maxRank.text = String.getValue(attempt!.maxRank)
        }
        totalQuestions.text = String(exam.numberOfQuestions)
        totalMarks.text = exam.totalMarks
        totalTime.text = String(exam.duration)
        if !exam.showScore || attempt.score == "NA" {
            scoreLayout.isHidden = true
        } else {
            score.text = attempt.score!
        }
        if !exam.showPercentile || attempt.percentile == 0 {
            percentileLayout.isHidden = true
        } else {
            percentile.text = String(attempt.percentile)
        }
        percentage.text = attempt.percentage
        cutoff.text = String(exam.passPercentage)
        correct.text = String(attempt!.correctCount)
        incorrect.text = String(attempt!.incorrectCount)
        timeTaken.text = attempt!.timeTaken ?? "NA"
        accuracy.text = String(attempt!.accuracy) + "%"
        UIUtils.setButtonDropShadow(solutionsButton)
        UIUtils.setButtonDropShadow(analyticsButton)
        UIUtils.setButtonDropShadow(timeAnalyticsButton)
        showOrHideLockIconInSolutionButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        showOrHideLockIconInSolutionButton()
    }
    
    func showOrHideLockIconInSolutionButton() {
        if ((exam.isGrowthHackEnabled ?? false) && (exam.getNumberOfTimesShared() < 2)) {
            shareButtonLayout.isHidden = false
            analyticsButtonLayout.isHidden = true
            solutionButtonLayout.isHidden = true
            shareButton.tintColor = Colors.getRGB(Colors.PRIMARY_TEXT)
            shareButton.setTitleColor(Colors.getRGB(Colors.PRIMARY_TEXT), for: .normal)
            shareButton.backgroundColor = Colors.getRGB(Colors.PRIMARY)
            shareButton.imageView?.contentMode = .scaleAspectFit
            shareButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        } else {
            shareButtonLayout.isHidden = true
            showOrHideAnalytics()
            showOrHideSolutions()
            solutionsButton.setImage(nil, for: .normal)
        }
    }

    private func showOrHideSolutions() {
        if (exam.showAnswers) {
            solutionButtonLayout.isHidden = false
        } else {
            solutionButtonLayout.isHidden = true
        }
    }

    @IBAction func showShareScreen(_ sender: Any) {
        let storyboard = UIStoryboard(name: Constants.MAIN_STORYBOARD, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier:
            Constants.SHARE_TO_UNLOCK_VIEW_CONTROLLER) as! ShareToUnlockViewController
        viewController.shareText = exam.shareTextForSolutionUnlock ?? ""
        viewController.onShareCompletion = {
            self.exam.incrementNumberOfTimesShared()
            if (self.exam.getNumberOfTimesShared() >= 2) {
                viewController.dismiss(animated: false) {
                    self.showSolutionsScreen()
                }
            }
        }
        self.present(viewController, animated: true, completion: nil)
    }
    
    private func showOrHideAnalytics() {
        if (exam.showAnalytics) {
            analyticsButtonLayout.isHidden = false
        } else {
            analyticsButtonLayout.isHidden = true
        }
    }

    @IBAction func showSolutions(_ sender: UIButton) {
        showSolutionsScreen()
    }

    
    func showSolutionsScreen() {
        let slideMenuController = self.storyboard?.instantiateViewController(withIdentifier:
        Constants.REVIEW_NAVIGATION_VIEW_CONTROLLER) as! UINavigationController
    
        let viewController =
        slideMenuController.viewControllers.first as! ReviewSlidingViewController
    
        viewController.exam = exam
        viewController.attempt = attempt
        self.present(slideMenuController, animated: true, completion: nil)
    }
    
    @IBAction func showSubjectAnalytics(_ sender: UIButton) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier:
            Constants.SUBJECT_ANALYTICS_TAB_VIEW_CONTROLLER) as! SubjectAnalyticsTabViewController
        
        viewController.analyticsUrl = attempt!.url + TPEndpoint.getAttemptSubjectAnalytics.urlPath
        present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func showTimeAnalytics(_ sender: UIButton) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier:
            Constants.TIME_ANALYTICS_TABLE_VIEW_CONTROLLER) as! TimeAnalyticsTableViewController
        
        viewController.attempt = attempt
        present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        let presentingViewController =
            self.presentingViewController?.presentingViewController?.presentingViewController
        
        if let contentDetailPageViewController =
            presentingViewController as? ContentDetailPageViewController {
            
            goToContentDetailPageViewController(contentDetailPageViewController)
        } else if let nvc =  presentingViewController as? UINavigationController,
                let accessCodeExamsViewController =
                    nvc.viewControllers.first as? AccessCodeExamsViewController {
            
            goToAccessCodeExamsViewController(accessCodeExamsViewController)
        } else if presentingViewController is UITabBarController,
                let tabViewController =
                    presentingViewController?.children[0] as? ExamsTabViewController {
            
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
                attemptsListViewController.loadAttemptsWithProgress(url: self.exam!.attemptsUrl)
            })
        } else if let contentDetailPageViewController =
            presentingViewController?.presentingViewController as? ContentDetailPageViewController {
            
            goToContentDetailPageViewController(contentDetailPageViewController)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func goToContentDetailPageViewController(_ contentDetailPageViewController: UIViewController) {
        let contentDetailPageViewController =
            contentDetailPageViewController as! ContentDetailPageViewController
        
        contentDetailPageViewController.dismiss(animated: false, completion: {
            if Double(self.attempt.percentage) ?? 0 >= self.exam.passPercentage {
                let currentIndex = contentDetailPageViewController.getCurrentIndex()
                let nextContent =
                    contentDetailPageViewController.contents[currentIndex]
                try! Realm().write {
                    nextContent.isLocked = false
                }
            }
            contentDetailPageViewController.updateCurrentExamContent()
        })
    }
    
    func goToAccessCodeExamsViewController(_ viewController: AccessCodeExamsViewController) {
        viewController.items.removeAll()
        viewController.dismiss(animated: false, completion: nil)
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
