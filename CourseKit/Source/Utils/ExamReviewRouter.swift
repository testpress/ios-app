//
//  ExamReviewRouter.swift
//  CourseKit
//
//  Copyright © 2024 Testpress. All rights reserved.
//

import UIKit

public enum ExamReviewRouter {

    public static func showExamReview(from viewController: UIViewController,exam: Exam?,contentAttempt: ContentAttempt?,attempt: Attempt?) {
        let storyboard = getStoryboard()

        if let contentAttempt = contentAttempt {
            presentTrophiesReport(from: viewController, exam: exam, contentAttempt: contentAttempt, storyboard: storyboard)
        } else if let attempt = attempt {
            presentTestReport(from: viewController, exam: exam, attempt: attempt, storyboard: storyboard)
        }
    }

    private static func getStoryboard() -> UIStoryboard {
        return UIStoryboard(
            name: Constants.EXAM_REVIEW_STORYBOARD,
            bundle: TestpressCourse.bundle
        )
    }

    private static func presentTrophiesReport(from viewController: UIViewController,exam: Exam?,contentAttempt: ContentAttempt,storyboard: UIStoryboard) {
        guard let reviewViewController = storyboard.instantiateViewController(withIdentifier: Constants.TROPHIES_ACHIEVED_VIEW_CONTROLLER) as? TrophiesAchievedViewController else {
            assertionFailure("Failed to cast view controller to TrophiesAchievedViewController")
            return
        }

        reviewViewController.exam = exam
        reviewViewController.contentAttempt = contentAttempt

        viewController.present(reviewViewController, animated: true)
    }

    private static func presentTestReport(from viewController: UIViewController,exam: Exam?,attempt: Attempt,storyboard: UIStoryboard) {
        guard let reviewViewController = storyboard.instantiateViewController(withIdentifier: Constants.TEST_REPORT_VIEW_CONTROLLER) as? TestReportViewController else {
            assertionFailure("Failed to cast view controller to TestReportViewController")
            return
        }

        reviewViewController.exam = exam
        reviewViewController.attempt = attempt

        viewController.present(reviewViewController, animated: true)
    }
}
