//
//  StartExamScreenViewController.swift
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

import SlideMenuController
import UIKit
import RealmSwift

class StartExamScreenViewController: UIViewController {
    
    static let REGULAR_ATTEMPT = 0
    static let QUIZ_ATTEMPT = 1

    @IBOutlet weak var examTitle: UILabel!
    @IBOutlet weak var questionsCount: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var markPerQuestion: UILabel!
    @IBOutlet weak var negativeMarks: UILabel!
    @IBOutlet weak var startEndDate: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var webOnlyExamLabel: UILabel!
    @IBOutlet weak var bottomShadowView: UIView!
    @IBOutlet weak var startButtonLayout: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIStackView!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    @IBOutlet weak var languageContainer: UIStackView!
    @IBOutlet weak var selectLanguageLabel: UILabel!
    var activityIndicator: UIActivityIndicatorView!
    
    var languages = List<Language>()
    let alertController = UIUtils.initProgressDialog(message: "Please wait\n\n")
    var emptyView: EmptyView!
    var content: Content!
    var contentAttempt: ContentAttempt!
    var exam: Exam!
    var attempt: Attempt?
    var accessCode: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStatusBarColor()
        showLoading()
        
        emptyView = EmptyView.getInstance(parentView: scrollView)
        view.addSubview(emptyView)
        if content != nil && exam == nil {
            exam = content.exam
            if contentAttempt != nil && attempt == nil {
                attempt = contentAttempt.assessment
            }
        }
        fetchAvailableLanguages(url: Constants.BASE_URL+"/api/v2.3/exams/"+exam.slug+"/languages/")
        examTitle.text = exam.title
        questionsCount.text = String(exam.numberOfQuestions)
        if attempt?.remainingTime != nil {
            duration.text = attempt?.remainingTime!
            durationLabel.text = "Time Remaining"
        } else {
            duration.text = exam?.duration
        }
        markPerQuestion.text = exam?.markPerQuestion
        negativeMarks.text = exam?.negativeMarks
        startEndDate.text = FormatDate.format(dateString: exam?.startDate) + " -\n" +
            FormatDate.format(dateString: exam?.endDate)
        
        if exam?.examDescription != nil {
            descriptionLabel.text = exam?.examDescription
        } else {
            descriptionLabel.isHidden = true
        }
        if exam?.deviceAccessControl == "web" {
            // Hide start button for web only exams
            startButtonLayout.isHidden = true
        } else if content != nil && content.isLocked {
            webOnlyExamLabel.text = Strings.SCORE_GOOD_IN_PREVIOUS
            startButtonLayout.isHidden = true
        } else if !exam!.hasStarted() {
            webOnlyExamLabel.text =
                Strings.CAN_START_EXAM_ONLY_AFTER + FormatDate.format(dateString: exam?.startDate)
            
            startButtonLayout.isHidden = true
        } else if exam.hasEnded() {
            webOnlyExamLabel.text = Strings.EXAM_ENDED
            startButtonLayout.isHidden = true
        } else {
            webOnlyExamLabel.isHidden = true
            UIUtils.setButtonDropShadow(startButton)
            if attempt?.state! == Constants.STATE_RUNNING {
                startButton.setTitle("RESUME", for: .normal)
                navigationBarItem?.title = Strings.RESUME_EXAM
            }
        }
        initializeLanguageSelection()
    }
    
    func initializeLanguageSelection() {
        updateSelectedLanguageTitle()
        selectLanguageLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showLanguages))
        selectLanguageLabel.addGestureRecognizer(tapGesture)
    }
    
    func updateSelectedLanguageTitle() {
        if (exam.selectedLanguage != nil){
            selectLanguageLabel.text = exam.selectedLanguage?.title
        }
    }

    @objc func showLanguages() {
        let actionSheet = UIAlertController(title: "Select Language", message: nil, preferredStyle: .actionSheet)

        let languageOptions = self.getLanguageOptions()
        languageOptions.forEach { actionSheet.addAction($0) }

        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.selectLanguageLabel
            popoverController.permittedArrowDirections = [.up, .down]
        }

        present(actionSheet, animated: true, completion: nil)
    }


    private func getLanguageOptions() -> [UIAlertAction] {
        return exam.languages.map { language in
            UIAlertAction(title: language.title, style: .default) { _ in
                self.selectLanguageLabel.text = language.title
                self.setSelectedLanguage(language)
            }
        } + [UIAlertAction(title: "Cancel", style: .cancel, handler: nil)]
    }
    
    func fetchAvailableLanguages(url: String) {
            TPApiClient.getListItems(
                endpointProvider: TPEndpointProvider(.get, url: url),
                completion: {
                    testpressResponse, error in
                    
                    if let error = error {
                        self.showErrorView(error, url: url)
                        return
                    }
                    
                    self.languages.append(objectsIn: testpressResponse!.results)
                    
                    if !(testpressResponse!.next.isEmpty) {
                        self.fetchAvailableLanguages(url: testpressResponse!.next)
                    } else {
                        self.saveDataInDB(self.languages)
                        self.hideLoading()
                    }
    
            }, type: Language.self)
        }
    
    private func showErrorView(_ error: TPError, url: String) {
        var retryButtonText: String?
        var retryHandler: (() -> Void)?
        if error.kind == .network {
            retryButtonText = Strings.TRY_AGAIN
            retryHandler = {
                self.emptyView.hide()
                self.fetchAvailableLanguages(url: url)
            }
        }
        self.hideLoading()
        self.startButton.isHidden = true
        let (image, title, description) = error.getDisplayInfo()
        self.emptyView.show(image: image, title: title, description: description,
                            retryButtonText: retryButtonText,
                            retryHandler: retryHandler)
    }
    
    private func saveDataInDB(_ languages: List<Language>) {
        try! Realm().write {
            self.exam.languages.removeAll()
            self.exam.languages = languages
        }
        self.languageContainer.isHidden = languages.count < 2
    }
    
    private func showLoading() {
        activityIndicator = UIUtils.initActivityIndicator(parentView: view)
        activityIndicator.startAnimating()
    }
    
    private func hideLoading() {
        if self.activityIndicator.isAnimating {
            self.activityIndicator.stopAnimating()
        }
    }
    
    private func setSelectedLanguage(_ language: Language) {
        try! Realm().write {
            self.exam.selectedLanguage = language
        }
    }
    
    @IBAction func startExam(_ sender: UIButton) {
        if [ExamTemplateType.IELTS_TEMPLATE, ExamTemplateType.CTET_TEMPLATE].contains(exam.templateType) {
            startExamInWebview()
            return
        }

        if (exam.hasMultipleLanguages() && exam.selectedLanguage == nil){
            showLanguages()
            return
        }
        
        if (contentAttempt?.assessment?.state == "Running"){
            startExam(contentAttempt?.assessment?.attemptType ?? StartExamScreenViewController.REGULAR_ATTEMPT)
            return
        }
        if(exam.enableQuizMode) {
            showExamModePopUp(sender)
        } else {
            startExam(StartExamScreenViewController.REGULAR_ATTEMPT)
        }
    }
    
    private func startExamInWebview() {
        guard let exam = exam, let examStartUrl = exam.examStartUrl else {
            return
        }
        let webViewController = WebViewController()
        webViewController.url = "&next=\(examStartUrl)"
        webViewController.title = exam.title
        webViewController.useSSOLogin = true
        webViewController.shouldOpenLinksWithinWebview = true
        webViewController.displayNavbar = true
        webViewController.modalPresentationStyle = .fullScreen
        present(webViewController, animated: true, completion: nil)
    }

    
    private func showExamModePopUp(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: "Select Exam Mode", message: nil, preferredStyle: .actionSheet)
        let regularModeButton = UIAlertAction(title: "Regular Mode", style: .default) { _ in
            self.startExam(StartExamScreenViewController.REGULAR_ATTEMPT)
        }
        let quizModeButton = UIAlertAction(title: "Quiz Mode", style: .default) { _ in
            self.startExam(StartExamScreenViewController.QUIZ_ATTEMPT)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(regularModeButton)
        actionSheet.addAction(quizModeButton)
        actionSheet.addAction(cancelAction)
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.permittedArrowDirections = [.up, .down]
        }
        present(actionSheet, animated: true, completion: nil)
    }
    
    func startExam(_ examMode: Int) {
        present(alertController, animated: false, completion: nil)
        startButton.isHidden = true
        startAttempt(examMode)
    }
    
    @IBAction func back() {
        dismiss(animated: true, completion: nil)
    }
    
    func startAttempt(_ examMode: Int) {
        var endpointProvider: TPEndpointProvider
        if content != nil && contentAttempt == nil {
            endpointProvider = TPEndpointProvider(
                .post,
                url: content.getAttemptsUrl()
            )
            startAttempt(examMode: examMode, type: ContentAttempt.self, endpointProvider: endpointProvider)
            return
        } else if attempt == nil {
            var queryParams = [String: String]()
            if accessCode != nil {
                queryParams.updateValue(accessCode, forKey: Constants.ACCESS_CODE)
            }
            endpointProvider = TPEndpointProvider(
                .post,
                url: (exam?.attemptsUrl)!,
                queryParams: queryParams
            )
        } else {
            endpointProvider = TPEndpointProvider(
                .put,
                url: attempt!.url + TPEndpoint.resumeAttempt.urlPath
            )
        }
        startAttempt(examMode: examMode, type: Attempt.self, endpointProvider: endpointProvider)
    }
    
    func startAttempt<T: TestpressModel>(examMode: Int, type: T.Type, endpointProvider: TPEndpointProvider) {
        TPApiClient.request(
            type: type,
            endpointProvider: endpointProvider,
            parameters: ["attempt_type":examMode],
            completion: {
                attempt, error in
                
                if let error = error {
                    debugPrint(error.message ?? "No error")
                    debugPrint(error.kind)
                    var retryButtonText: String?
                    var retryHandler: (() -> Void)?
                    if error.kind == .network {
                        retryButtonText = Strings.TRY_AGAIN
                        retryHandler = {
                            self.present(self.alertController, animated: false, completion: nil)
                            self.startAttempt(examMode)
                        }
                    }
                    let (image, title, description) = error.getDisplayInfo()
                    self.emptyView.show(image: image, title: title, description: description,
                                        retryButtonText: retryButtonText,
                                        retryHandler: retryHandler)
                    
                    self.alertController.dismiss(animated: true, completion: nil)
                    return
                }
                
                self.alertController.dismiss(animated: true, completion: nil)
                if let contentAttempt = attempt as? ContentAttempt {
                    self.contentAttempt = contentAttempt
                    try! Realm().write{
                        self.content.attemptsCount += 1
                    }
                    self.attempt = contentAttempt.assessment
                } else {
                    self.attempt = attempt as? Attempt
                }
                if (self.attempt?.attemptType == StartExamScreenViewController.QUIZ_ATTEMPT){
                    self.goToQuizExam()
                } else {
                    self.gotoTestEngine()
                }
                
        })
    }
    
    func gotoTestEngine() {
        let storyboard = UIStoryboard(name: Constants.TEST_ENGINE, bundle: nil)
        let slideMenuController = storyboard.instantiateViewController(withIdentifier:
            Constants.TEST_ENGINE_NAVIGATION_CONTROLLER) as! UINavigationController
        
        let viewController =
            slideMenuController.viewControllers.first as! TestEngineSlidingViewController
        
        viewController.exam = exam
        viewController.attempt = attempt
        viewController.courseContent = content
        viewController.contentAttempt = contentAttempt
        present(slideMenuController, animated: true, completion: nil)
    }
    
    func goToQuizExam() {
        let storyboard = UIStoryboard(name: Constants.TEST_ENGINE, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier:
            Constants.QUIZ_EXAM_VIEW_CONTROLLER) as! QuizExamViewController
        viewController.contentAttempt = contentAttempt
        viewController.exam = content.exam
        present(viewController, animated: true, completion: nil)
    }
    
    // Set frames of the views in this method to support both portrait & landscape view
    override func viewDidLayoutSubviews() {
        // Add gradient shadow layer to the shadow container view
        if bottomShadowView != nil {
            let bottomGradient = CAGradientLayer()
            bottomGradient.frame = bottomShadowView.bounds
            bottomGradient.colors = [UIColor.white.cgColor, UIColor.black.cgColor]
            bottomShadowView.layer.insertSublayer(bottomGradient, at: 0)
        }
        
        // Set scroll view content height to support the scroll
        scrollView.contentSize.height = contentView.frame.size.height
    }
    
}
