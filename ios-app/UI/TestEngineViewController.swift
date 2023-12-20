//
//  TestEngineViewController.swift
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

import DropDown
import UIKit
import RealmSwift

class TestEngineViewController: BaseQuestionsPageViewController {
    
    @IBOutlet weak var dropdownContainer: UIView!
    @IBOutlet weak var dropdownContainerHeight: NSLayoutConstraint!
    
    static let DROP_DOWN_CONTAINER_HEIGHT = CGFloat(45)
    
    var remainingTime: Int = 0
    var timer: Timer = Timer()
    var parentSlidingViewController: TestEngineSlidingViewController!
    var sections: [AttemptSection] = []
    var currentSection: Int = 0
    var lockedSectionExam: Bool = false
    var firstAttemptOfLockedSectionExam: Bool = false
    var unlockedSectionExam: Bool = false
    var plainDropDown: PlainDropDown!
    var selectedPlainSpinnerItemOffset: Int = 0
    var navigationButtonPressed: Bool = false
    /**
     * Map of subjects/sections & its starting point(first question index)
     */
    var plainSpinnerItemOffsets = OrderedDictionary<String, Int>()
    var alertDialog: UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionsPageViewDelegate = self
        nextButton.setTitle("NEXT", for: .normal)
        
        setupPauseButtonGesture()
        initializeDropDownContainerForSections()
        
        if !firstAttemptOfLockedSectionExam {
            nextButton.setTitleColor(Colors.getRGB(Colors.MATERIAL_RED), for: .disabled)
            nextButton.setTitle("END", for: .disabled)
        }

        showOrHideTimer()
    }
    
    private func setupPauseButtonGesture() {
        let pauseButtonGesture = UITapGestureRecognizer(target: self, action:
            #selector(self.onPressPauseButton(sender:)))
        parentSlidingViewController.pauseButtonLayout.addGestureRecognizer(pauseButtonGesture)
        
        let languageFilterGeester = UITapGestureRecognizer(target: self, action:
            #selector(self.showLanguages(sender:)))
        parentSlidingViewController.languagefilter.addGestureRecognizer(languageFilterGeester)
    }
    
    @objc func showLanguages(sender: UITapGestureRecognizer) {
        let actionSheet = UIAlertController(title: "Select Language", message: nil, preferredStyle: .actionSheet)

        let languageOptions = self.getLanguageOptions()
        languageOptions.forEach { actionSheet.addAction($0) }

        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.view
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
        setSelectedLanguage(language)
        baseQuestionsDataSource.setLanguage(language)
        parentSlidingViewController.questionListViewController?.setLanguage(language)
        setCurrentQuestion(index: getCurrentIndex())
    }
    
    private func setSelectedLanguage(_ language: Language) {
        try! Realm().write {
            self.exam?.selectedLanguage = language
        }
    }
    
    private func initializeDropDownContainerForSections() {
        hideDropdownContainer()
        checkExamHasLockedSection()
        setupSectionsDropDown()
    }
    
    private func showOrHideTimer(){
        if(exam == nil && attempt?.remainingTime == DEFAULT_EXAM_TIME) {
            parentSlidingViewController.remainingTimeLabel.isHidden = true
        }
    }
    
    private func hideDropdownContainer() {
        dropdownContainerHeight.constant = 0
        dropdownContainer.isHidden = true
    }
    
    private func checkExamHasLockedSection() {
        sections = Array(attempt.sections)
        if sections.count > 1 {
            for i in 0 ..< sections.count {
                if sections[i].state == Attempt.RUNNING {
                    currentSection = i
                }
                if sections[i].duration == "" || sections[i].duration == "0:00:00" {
                    unlockedSectionExam = true;
                }
            }
            lockedSectionExam = !unlockedSectionExam;
        }
    }
    
    private func setupSectionsDropDown() {
        if lockedSectionExam {
            setUpDropDownForLockedSections()
        } else {
            setUpDropDownForSections()
        }
    }
    
    private func setUpDropDownForLockedSections() {
        plainDropDown = PlainDropDown(containerView: dropdownContainer)
        plainDropDown.dropDown.selectionBackgroundColor = UIColor.clear
        plainDropDown.dropDown.cellNib =
        UINib(nibName: "LockableSectionDropDownCell", bundle: nil)
        
        plainDropDown.dropDown.customCellConfiguration = {
            (index: Index, item: String, cell: DropDownCell) -> Void in
            
            let cell = cell as! LockableSectionDropDownCell
            let selectedItemIndex = self.plainDropDown.dropDown.indexForSelectedRow
            cell.initCell(index: index, sectionName: item, selectedItem: selectedItemIndex!)
        }
        for section in sections {
            plainDropDown.items.append(section.name)
        }
        plainDropDown.addItems(items: plainDropDown.items)
        plainDropDown.setCurrentItem(index: currentSection)
        dropdownContainerHeight.constant =
        TestEngineViewController.DROP_DOWN_CONTAINER_HEIGHT
        
        dropdownContainer.isHidden = false
        plainDropDown.dropDown.selectionAction = { (index: Int, item: String) in
            if index == self.currentSection {
                return
            }
            self.onSwitchLockedSection(index: index)
        }
        firstAttemptOfLockedSectionExam = isFirstCourseContentAttempt() || isFirstExamAttempt()
    }

    private func isFirstCourseContentAttempt() -> (Bool) {
        return (courseContent != nil && courseContent.attemptsCount <= 1)
    }
    
    private func isFirstExamAttempt() -> (Bool) {
        return (courseContent == nil && (exam!.attemptsCount == 0 || (exam!.attemptsCount == 1 && exam!.pausedAttemptsCount == 1)))
    }
    
    private func setUpDropDownForSections() {
        if exam != nil && (exam!.templateType == 2 || unlockedSectionExam) {
            plainDropDown = PlainDropDown(containerView: dropdownContainer)
            plainDropDown.dropDown.selectionAction = { (index: Int, item: String) in
                self.plainDropDown.titleButton.setTitle(item, for: .normal)
                self.selectedPlainSpinnerItemOffset = self.plainSpinnerItemOffsets[item]!
                self.setCurrentQuestion(index: self.plainSpinnerItemOffsets[item]!)
            }
        }
    }
    
    func onSwitchLockedSection(index: Int) {
        plainDropDown.setCurrentItem(index: currentSection)
        if firstAttemptOfLockedSectionExam {
            alertDialog = UIUtils.showSimpleAlert(
                title: Strings.CANNOT_SWITCH_SECTION,
                message: Strings.CANNOT_SWITCH_IN_FIRST_ATTEMPT,
                viewController: self,
                positiveButtonText: Strings.OK,
                cancelable: true,
                cancelHandler: #selector(closeAlert)
            )
        } else if currentSection > index {
            alertDialog = UIUtils.showSimpleAlert(
                title: Strings.CANNOT_SWITCH_SECTION,
                message: Strings.ALREADY_SUBMITTED,
                viewController: self,
                positiveButtonText: Strings.OK,
                cancelable: true,
                cancelHandler: #selector(closeAlert)
            )
        } else if currentSection + 1 < index {
            alertDialog = UIUtils.showSimpleAlert(
                title: Strings.CANNOT_SWITCH_SECTION,
                message: Strings.ATTEMPT_SECTION_IN_ORDER,
                viewController: self,
                positiveButtonText: Strings.OK,
                cancelable: true,
                cancelHandler: #selector(closeAlert)
            )
        } else {
            showSectionSwitchAlert()
        }
    }
    
    func showSectionSwitchAlert() {
        alertDialog = UIUtils.showSimpleAlert(
            title: Strings.SWITCH_SECTION,
            message: Strings.SWITCH_SECTION_MESSAGE,
            viewController: self,
            positiveButtonText: Strings.END_SECTION,
            cancelable: true,
            cancelHandler: #selector(closeAlert),
            completion: { action in
                self.onClickEnd()
        })
    }
    
    override func loadQuestions(url: String) {
        if lockedSectionExam {
            loadingDialogController.message = Strings.LOADING_SECTION_QUESTIONS
        }
        return super.loadQuestions(url: url)
    }
    
    override func getQuestionsDataSource() -> BaseQuestionsDataSource {
        return QuestionsControllerSource(attemptItems, exam?.selectedLanguage)
    }
    
    override func getQuestionsUrl() -> String {
        if lockedSectionExam {
            return sections[currentSection].questionsUrl
        }
        return attempt!.questionsUrl!
    }
    
    override func onClickNextButton(sender: UITapGestureRecognizer) {
        var  index = getCurrentIndex()
        index += 1
        if index == baseQuestionsDataSource.attemptItems.count {
            if !firstAttemptOfLockedSectionExam {
                if lockedSectionExam && currentSection + 1 < sections.count {
                    showSectionSwitchAlert()
                } else {
                    onPressStopButton()
                }
            }
            return
        }
        
        super.onClickNextButton(sender: sender)
    }
    
    override func setCurrentQuestion(index: Int) {
        super.setCurrentQuestion(index: index)
        if !lockedSectionExam && plainDropDown != nil && plainDropDown.items.count > 1 {
            var currentSpinnerItem: String
            let currentAttemptItem = attemptItems[getCurrentIndex()]
            if unlockedSectionExam {
                currentSpinnerItem = currentAttemptItem.attemptSection!.name
            } else {
                currentSpinnerItem = currentAttemptItem.question.subject
            }
            if selectedPlainSpinnerItemOffset != plainSpinnerItemOffsets[currentSpinnerItem] {
                selectedPlainSpinnerItemOffset = plainSpinnerItemOffsets[currentSpinnerItem]!
                let currentSpinnerItemIndex = plainDropDown.items.index(of: currentSpinnerItem)!
                plainDropDown.setCurrentItem(index: currentSpinnerItemIndex)
            }
        }
    }
    
    @objc func onTimerFire() {
        if(remainingTime > 0) {
            remainingTime -= 1
            let (hours, minutes, seconds) = updateRemainingTime()
            if hours != 0 || minutes != 0 || seconds != 0 {
                if (remainingTime % 60) == 0 {
                    sendHeartBeat();
                }
                return
            }
        }
        if alertDialog != nil && alertDialog.presentingViewController != nil {
            alertDialog.dismiss(animated: false, completion: {
                self.onClickEnd()
            })
        } else {
            onClickEnd()
        }
    }
    
    @discardableResult
    func updateRemainingTime() -> (Int, Int, Int) {
        let hours = (remainingTime / (60 * 60)) % 12
        let minutes = (remainingTime / 60) % 60
        let seconds = remainingTime % 60
        parentSlidingViewController.remainingTimeLabel.text =
            String(format: "%d:%02d:%02d", hours, minutes, seconds)
        
        return (hours, minutes, seconds)
    }
    
    func sendHeartBeat() {
        TPApiClient.updateAttemptState(
            endpointProvider: TPEndpointProvider(
                .sendHeartBeat,
                url: attempt!.url + TPEndpoint.sendHeartBeat.urlPath
            ),
            completion: {
                attempt, error in
                if let error = error {
                    self.loadingDialogController.message = Strings.PLEASE_WAIT + "\n\n"
                    self.showAlert(error: error, retryHandler: { self.sendHeartBeat() })
                    return
                }
                
                if self.showingProgress {
                    self.startTimer()
                    self.loadingDialogController.dismiss(animated: true)
                    self.showingProgress = false
                }
            }
        )
    }
    
    func saveAnswer(index: Int, completionHandler: (() -> Void)? = nil) {
        let attemptItem = attemptItems[index]
        if attemptItem.hasChanged() {
            loadingDialogController.message = Strings.SAVING_LAST_CHANGE
            TPApiClient.saveAnswer(
                selectedAnswer: Array(attemptItem.savedAnswers),
                review: attemptItem.currentReview,
                shortAnswer: attemptItem.currentShortText,
                gapFilledResponses: attemptItem.gapFillResponses,
                endpointProvider: TPEndpointProvider(.saveAnswer, url: attemptItem.url),
                attemptItem: attemptItem,
                completion: {
                    newAttemptItem, error in
                    if let error = error {
                        
                        if error.error_code == "max_attemptable_questions_limit_reached" {
                            self.showMaxQuestionsAttemptedError(error: error)
                            self.setCurrentQuestion(index: index)
                        } else {
                            self.showAlert(error: error, retryHandler: {
                                self.saveAnswer(index: index, completionHandler: completionHandler)
                            })
                        }
                        return
                    }
                    
                    if completionHandler != nil {
                        // Saved the answer on user paused or end the exam  0x600000b2ddd0
                        self.hideLoadingProgress(completionHandler: completionHandler)
                        return
                    }
                    try! Realm().write {
                        // Saved the answer on user navigate to other question
                        attemptItem.selectedAnswers = newAttemptItem!.selectedAnswers
                        attemptItem.review = newAttemptItem!.review
                        attemptItem.shortText = newAttemptItem!.shortText
                        attemptItem.essayText = newAttemptItem?.essayText
                    }
                    self.attemptItems[index] = attemptItem;
                    
                    if self.showingProgress {
                        self.startTimer()
                        self.loadingDialogController.dismiss(animated: false)
                        self.showingProgress = false
                    }
                }
            )
        } else {
            if completionHandler != nil {
                completionHandler!()
            }
        }
    }
    
    func showMaxQuestionsAttemptedError(error: TPError) {
        var alert: UIAlertController
        var cancelButtonTitle: String
        
        alert = UIAlertController(
            title: "Maximum questions attempted",
            message: error.error_detail,
            preferredStyle: UIAlertController.Style.alert
        )
        cancelButtonTitle = "OK"
        
        alert.addAction(UIAlertAction(
            title: cancelButtonTitle, style: UIAlertAction.Style.default
        ))
        
        if showingProgress {
            hideLoadingProgress(completionHandler: {
                self.present(alert, animated: true, completion: nil)
            })
        } else {
            present(alert, animated: true, completion: nil)
        }
    }
    
    func endSection() {
        loadingDialogController.message = Strings.ENDING_SECTION
        TPApiClient.request(
            type: AttemptSection.self,
            endpointProvider: TPEndpointProvider(.put, url: sections[currentSection].endUrl),
            completion: {
                attemptSection, error in
                if let error = error {
                    self.showAlert(
                        error: error,
                        message: Strings.EXAM_PAUSED_CHECK_INTERNET_TO_END,
                        retryHandler: { self.endSection() }
                    )
                    return
                }
                
                self.sections[self.currentSection] = attemptSection!
                self.currentSection += 1
                if self.currentSection == self.sections.count {
                    self.endExam()
                } else {
                    self.plainDropDown.setCurrentItem(index: self.currentSection)
                    self.startSection()
                }
        })
    }
    
    func startSection() {
        loadingDialogController.message = Strings.STARTING_SECTION
        TPApiClient.request(
            type: AttemptSection.self,
            endpointProvider: TPEndpointProvider(.put, url: sections[currentSection].startUrl),
            completion: {
                attemptSection, error in
                if let error = error {
                    self.showAlert(error: error, retryHandler: { self.startSection() })
                    return
                }
                
                self.sections[self.currentSection] = attemptSection!
                self.attemptItems = []
                self.loadQuestions(url: self.getQuestionsUrl())
        })
    }
    
    func onClickEnd() {
        showLoadingProgress(completionHandler: {
            self.saveAnswer(index: self.getCurrentIndex(), completionHandler: {
                if self.lockedSectionExam {
                    self.endSection()
                } else {
                    self.endExam()
                }
            })
        })
    }
    
    func endExam() {
        var endpointProvider: TPEndpointProvider
        if contentAttempt != nil {
            endpointProvider = TPEndpointProvider(.put, url: contentAttempt.getEndAttemptUrl())
            endExam(type: ContentAttempt.self, endpointProvider: endpointProvider)
        } else {
            endpointProvider = TPEndpointProvider(
                .put,
                url: attempt!.url + TPEndpoint.endExam.urlPath
            )
            endExam(type: Attempt.self, endpointProvider: endpointProvider)
        }
    }
    
    func endExam<T: TestpressModel>(type: T.Type, endpointProvider: TPEndpointProvider) {
        loadingDialogController.message = Strings.ENDING_EXAM
        TPApiClient.request(
            type: type,
            endpointProvider: endpointProvider,
            completion: {
                attempt, error in
                if let error = error {
                    self.showAlert(
                        error: error,
                        message: Strings.EXAM_PAUSED_CHECK_INTERNET_TO_END,
                        retryHandler: { self.endExam() }
                    )
                    return
                }
                
                if let contentAttempt = attempt as? ContentAttempt {
                    self.contentAttempt = contentAttempt
                    self.attempt = contentAttempt.assessment
                } else {
                    self.attempt = attempt as? Attempt
                }
                self.hideLoadingProgress(completionHandler: {
                    self.gotoTestReport()
                })
        }
        )
    }
    
    override func showAlert(error: TPError,
                            message: String = Strings.EXAM_PAUSED_CHECK_INTERNET,
                            retryHandler: @escaping (() -> Swift.Void)) {
        
        timer.invalidate()
        super.showAlert(error: error, message: message, retryHandler: retryHandler)
    }
    
    @objc func onPressPauseButton(sender: UITapGestureRecognizer) {
        if exam == nil {
            showEndExamDialog()
            return
        }
        alertDialog = UIAlertController(title: Strings.EXIT_EXAM,
                                      message: Strings.PAUSE_MESSAGE,
                                      preferredStyle: .alert)
        
        alertDialog.addAction(UIAlertAction(
            title: Strings.YES,
            style: UIAlertAction.Style.default,
            handler: { action in
                self.showLoadingProgress(completionHandler: {
                    self.saveAnswer(index: self.getCurrentIndex(), completionHandler: {
                        self.goBack()
                    })
                })
            }
        ))
        alertDialog.addAction(
            UIAlertAction(title: Strings.CANCEL, style: UIAlertAction.Style.cancel))
        
        present(alertDialog, animated: true, completion: {
            self.alertDialog.view.superview?.isUserInteractionEnabled = true
            self.alertDialog.view.superview?.addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(self.closeAlert(gesture:))
            ))
        })
    }
    
    @objc func closeAlert(gesture: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    func onPressStopButton() {
        if exam == nil {
            showEndExamDialog()
            return
        }
        alertDialog = UIAlertController(
            title: Strings.EXIT_EXAM,
            message: Strings.END_MESSAGE,
            preferredStyle: UIUtils.getActionSheetStyle()
        )
        alertDialog.addAction(UIAlertAction(
            title: Strings.PAUSE, style: UIAlertAction.Style.default, handler: {
                (action: UIAlertAction!) in
                self.showLoadingProgress(completionHandler: {
                    self.saveAnswer(index: self.getCurrentIndex(), completionHandler: {
                        self.goBack()
                    })
                })
            }
        ))
        if !firstAttemptOfLockedSectionExam {
            alertDialog.addAction(UIAlertAction(
                title: Strings.END, style: UIAlertAction.Style.destructive,
                handler: { (action: UIAlertAction!) in
                    if self.lockedSectionExam &&
                        self.currentSection + 1 < self.sections.count {
                        
                        self.showSectionSwitchAlert()
                    } else {
                        self.onClickEnd()
                    }
                }
            ))
        }
        alertDialog.addAction(UIAlertAction(
            title: Strings.CANCEL,
            style: UIAlertAction.Style.cancel
        ))
        present(alertDialog, animated: true, completion: nil)
    }

    func showEndExamDialog() {
        alertDialog = UIAlertController(
            title: Strings.EXIT_EXAM,
            message: "Are you sure? Want to end the exam",
            preferredStyle: UIUtils.getActionSheetStyle()
        )
        alertDialog.addAction(UIAlertAction(
            title: Strings.END, style: UIAlertAction.Style.destructive,
            handler: { (action: UIAlertAction!) in
                self.onClickEnd()
            }
        ))
        alertDialog.addAction(UIAlertAction(
            title: Strings.CANCEL,
            style: UIAlertAction.Style.cancel
        ))
        present(alertDialog, animated: true, completion: nil)
    }
    
    func gotoTestReport() {
        let storyboard = UIStoryboard(name: Constants.EXAM_REVIEW_STORYBOARD, bundle: nil)
        if contentAttempt != nil {
            let viewController = storyboard.instantiateViewController(withIdentifier:
                Constants.TROPHIES_ACHIEVED_VIEW_CONTROLLER) as! TrophiesAchievedViewController
            
            viewController.exam = exam
            viewController.contentAttempt = contentAttempt
            present(viewController, animated: true, completion: nil)
        } else {
            let viewController = storyboard.instantiateViewController(withIdentifier:
                Constants.TEST_REPORT_VIEW_CONTROLLER) as! TestReportViewController
            
            viewController.exam = exam
            viewController.attempt = attempt
            present(viewController, animated: true, completion: nil)
        }
    }
    
    func getSecondsFromInputString(_ inputString: String?) -> Int {
        if inputString == nil || inputString == "0:00:00" {
            return 0
        }
        
        return inputString?.secondsFromString ?? 0
    }
    
    func startTimer() {
        updateRemainingTime()
        timer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(self.onTimerFire),
            userInfo: nil,
            repeats: true
        )
        RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
    }
    
    override func showLoadingProgress(completionHandler: (() -> Void)?) {
        timer.invalidate()
        super.showLoadingProgress(completionHandler: completionHandler)
    }

}

extension TestEngineViewController: QuestionsPageViewDelegate {
    
    func questionsDidLoad() {
        if sections.count <= 1 && exam != nil && (exam!.templateType == 2 || unlockedSectionExam) {
            // Used to get items in order as it fetched
            var spinnerItemsList = [String]()
            var groupedAttemptItems = OrderedDictionary<String, [AttemptItem]>()
            for attemptItem in attemptItems {
                if unlockedSectionExam {
                    let section = attemptItem.attemptSection!.name
                    groupAttemptItems(
                        spinnerItem: section,
                        attemptItem: attemptItem,
                        spinnerItemsList: &spinnerItemsList,
                        groupedAttemptItems: &groupedAttemptItems
                    )
                } else {
                    let subject = attemptItem.question.subject
                    if subject.isEmpty {
                        try! Realm().write {
                            // If subject is empty, subject = "Uncategorized"
                            attemptItem.question.subject = Constants.UNCATEGORIZED
                        }
                    }
                    groupAttemptItems(
                        spinnerItem: subject,
                        attemptItem: attemptItem,
                        spinnerItemsList: &spinnerItemsList,
                        groupedAttemptItems: &groupedAttemptItems
                    )
                }
            }
            if spinnerItemsList.count > 1 {
                // Clear the previous data stored while loading which might be unordered
                attemptItems = []
                // Store each set of items to attemptItemList
                for spinnerItem in spinnerItemsList {
                    // Add spinner item & it starting point
                    plainSpinnerItemOffsets[spinnerItem] = attemptItems.count
                    attemptItems.append(contentsOf: groupedAttemptItems[spinnerItem]!)
                }
                plainDropDown.addItems(items: spinnerItemsList)
                dropdownContainerHeight.constant =
                    TestEngineViewController.DROP_DOWN_CONTAINER_HEIGHT
                
                dropdownContainer.isHidden = false
                selectedPlainSpinnerItemOffset = 0
                plainDropDown.setCurrentItem(index: 0)
            }
        }
        
        remainingTime = getSecondsFromInputString(attempt.remainingTime)
        if lockedSectionExam {
            remainingTime = getSecondsFromInputString(sections[currentSection].remainingTime)
        }
        startTimer()
    }
    
    func groupAttemptItems(spinnerItem: String,
                           attemptItem: AttemptItem,
                           spinnerItemsList: inout [String],
                           groupedAttemptItems: inout OrderedDictionary<String, [AttemptItem]>) {
        
        if groupedAttemptItems.keys.contains(spinnerItem) {
            // Check spinnerItem is already added if added simply add the item it
            groupedAttemptItems[spinnerItem]!.append(attemptItem)
        } else {
            // Add the spinnerItem & then add item to it
            groupedAttemptItems[spinnerItem] = [AttemptItem]()
            groupedAttemptItems[spinnerItem]!.append(attemptItem)
            spinnerItemsList.append(spinnerItem)
        }
    }
    
    func currentQuestionDidChange(previousIndex: Int, currentIndex: Int) {
         saveAnswer(index: previousIndex)
    }
    
    func goBack() {
        let presentingViewController = self.presentingViewController?.presentingViewController
        if self.presentingViewController! is ContentDetailPageViewController {
            
            let contentDetailPageViewController  =
                self.presentingViewController! as! ContentDetailPageViewController
            
            contentDetailPageViewController.dismiss(animated: false, completion: {
                contentDetailPageViewController.updateCurrentExamContent()
            })
        } else if let nvc =  presentingViewController as? UINavigationController,
                let accessCodeExamsViewController =
                    nvc.viewControllers.first as? AccessCodeExamsViewController {
            
            accessCodeExamsViewController.items.removeAll()
            accessCodeExamsViewController.dismiss(animated: false, completion: nil)
        } else if presentingViewController is UITabBarController {
            let tabViewController =
                presentingViewController?.children[0] as! ExamsTabViewController
            
            tabViewController.dismiss(animated: false, completion: {
                if tabViewController.currentIndex != 2 {
                    // Move to histroy tab
                    tabViewController.moveToViewController(at: 2, animated: true)
                }
                // Refresh the list items
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
        } else if presentingViewController is ContentDetailPageViewController {
            
            let contentDetailPageViewController =
                presentingViewController as! ContentDetailPageViewController
            
            contentDetailPageViewController.dismiss(animated: false, completion: {
                contentDetailPageViewController.updateCurrentExamContent()
            })
        } else {
            debugPrint(type(of: presentingViewController!))
            dismiss(animated: true, completion: nil)
        }
    }
}

extension TestEngineViewController: SlidingMenuDelegate {
    
    func dismissViewController() {
        onPressStopButton()
    }
}

