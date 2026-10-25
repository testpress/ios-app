//
//  ExamReviewRouter.swift
//  CourseKit
//
//  Copyright © 2024 Testpress. All rights reserved.
//

import UIKit

public enum ExamReviewRouter {

    public static func showExamReview(from viewController: UIViewController, exam: Exam?, contentAttempt: ContentAttempt?, attempt: Attempt?) {
        var resolvedExam = exam
        let userExamId = contentAttempt?.assessment?.id ?? attempt?.id
        let examId = contentAttempt?.assessment?.exam ?? attempt?.exam ?? 0

        if (resolvedExam == nil || resolvedExam?.isInvalidated == true), examId > 0 {
            resolvedExam = Exam.find(by: examId)
        }

        let isQuiz = (contentAttempt?.assessment?.attemptType ?? attempt?.attemptType) == StartExamScreenViewController.QUIZ_ATTEMPT

        if Reachability.isConnectedToNetwork(),
           let currentExam = resolvedExam,
           currentExam.enableMindsetReflections,
           let postForm = currentExam.postExamReflectionForm,
           let attemptId = userExamId,
           attemptId > 0,
           !isQuiz {
            let webViewController = MindsetReflectionViewController()
            webViewController.url = postForm.getPostExamSSOUrl(examId: currentExam.id, attemptId: attemptId)
            webViewController.submissionMandatory = postForm.submissionMandatory
            webViewController.modalPresentationStyle = .fullScreen

            let targetExamId = currentExam.id
            let navigateToReview: () -> Void = {
                let latestExam = Exam.find(by: targetExamId)
                presentNativeExamReview(from: viewController, exam: latestExam, contentAttempt: contentAttempt, attempt: attempt)
            }
            webViewController.onReflectionSubmitted = navigateToReview
            webViewController.onReflectionSkipped = navigateToReview
            webViewController.onBackButtonPressed = navigateToReview

            viewController.present(webViewController, animated: true, completion: nil)
        } else {
            presentNativeExamReview(from: viewController, exam: resolvedExam, contentAttempt: contentAttempt, attempt: attempt)
        }
    }

    private static func presentNativeExamReview(from viewController: UIViewController, exam: Exam?, contentAttempt: ContentAttempt?, attempt: Attempt?) {
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
