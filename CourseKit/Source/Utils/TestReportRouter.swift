//
//  TestReportRouter.swift
//  CourseKit
//
//  Copyright © 2024 Testpress. All rights reserved.
//

import UIKit

public class TestReportRouter {
    public static func routeToTestReport(from viewController: UIViewController, exam: Exam?, contentAttempt: ContentAttempt?, attempt: Attempt?) {
        let storyboard = UIStoryboard(name: Constants.EXAM_REVIEW_STORYBOARD, bundle: TestpressCourse.bundle)
        if let contentAttempt = contentAttempt {
            let vc = storyboard.instantiateViewController(withIdentifier:
                Constants.TROPHIES_ACHIEVED_VIEW_CONTROLLER) as! TrophiesAchievedViewController
            vc.exam = exam
            vc.contentAttempt = contentAttempt
            viewController.present(vc, animated: true, completion: nil)
        } else {
            let vc = storyboard.instantiateViewController(withIdentifier:
                Constants.TEST_REPORT_VIEW_CONTROLLER) as! TestReportViewController
            vc.exam = exam
            vc.attempt = attempt
            viewController.present(vc, animated: true, completion: nil)
        }
    }
}
