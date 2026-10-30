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
        let attemptId = userExamId
        let isReflectionCompleted = (attemptId != nil && attemptId! > 0) ? UserDefaults.standard.bool(forKey: "post_exam_reflection_completed_\(attemptId!)") : false

        if Reachability.isConnectedToNetwork(),
           let currentExam = resolvedExam,
           currentExam.enableMindsetReflections,
           !isReflectionCompleted,
           !isQuiz,
           let attemptId = attemptId,
           attemptId > 0 {

            if let postForm = currentExam.postExamReflectionForm {
                let webViewController = MindsetReflectionViewController()
                webViewController.url = postForm.getPostExamSSOUrl(examId: currentExam.id, attemptId: attemptId)
                webViewController.submissionMandatory = postForm.submissionMandatory
                webViewController.modalPresentationStyle = .fullScreen

                let targetExamId = currentExam.id
                let markCompleted = {
                    UserDefaults.standard.set(true, forKey: "post_exam_reflection_completed_\(attemptId)")
                }
                let navigateToReview: () -> Void = {
                    let latestExam = Exam.find(by: targetExamId) ?? (currentExam.isInvalidated ? nil : currentExam)
                    presentNativeExamReview(from: viewController, exam: latestExam, contentAttempt: contentAttempt, attempt: attempt)
                }
                webViewController.onReflectionSubmitted = {
                    markCompleted()
                    navigateToReview()
                }
                webViewController.onReflectionSkipped = {
                    markCompleted()
                    navigateToReview()
                }
                webViewController.onBackButtonPressed = navigateToReview

                viewController.present(webViewController, animated: true, completion: nil)
                return
            } else if !currentExam.slug.isEmpty {
                // When an exam was cached prior to postExamReflectionForm support (or reached without StartExamScreen),
                // fetch the exam detail to obtain postExamReflectionForm before navigating to review.
                let examUrl = TestpressCourse.shared.baseURL + "/api/v2.2/exams/" + currentExam.slug + "/"
                TPApiClient.request(
                    type: Exam.self,
                    endpointProvider: TPEndpointProvider(.get, url: examUrl),
                    completion: { fetchedExam, error in
                        DispatchQueue.main.async {
                            if let fetchedExam = fetchedExam, error == nil {
                                if let realm = currentExam.realm, !currentExam.isInvalidated {
                                    DBManager<Exam>().write {
                                        currentExam.enableMindsetReflections = fetchedExam.enableMindsetReflections
                                        if let postForm = fetchedExam.postExamReflectionForm {
                                            currentExam.postExamReflectionForm = realm.create(MindsetReflectionForm.self, value: postForm, update: .modified)
                                        } else {
                                            currentExam.postExamReflectionForm = nil
                                        }
                                    }
                                } else {
                                    currentExam.enableMindsetReflections = fetchedExam.enableMindsetReflections
                                    currentExam.postExamReflectionForm = fetchedExam.postExamReflectionForm
                                }
                                showExamReview(from: viewController, exam: currentExam, contentAttempt: contentAttempt, attempt: attempt)
                            } else {
                                presentNativeExamReview(from: viewController, exam: currentExam, contentAttempt: contentAttempt, attempt: attempt)
                            }
                        }
                    }
                )
                return
            }
        }

        presentNativeExamReview(from: viewController, exam: resolvedExam, contentAttempt: contentAttempt, attempt: attempt)
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
