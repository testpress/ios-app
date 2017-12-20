//
//  ContentExamAttemptsTableViewController.swift
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

class ContentExamAttemptsTableViewController: UITableViewController {
    
    var activityIndicator: UIActivityIndicatorView! // Progress bar
    var emptyView: EmptyView!
    var content: Content!
    var exam: Exam!
    var attempts: [ContentAttempt] = []
    var pausedAttempts: [ContentAttempt] = []
    
    override func viewDidLoad() {
        emptyView = EmptyView.getInstance(parentView: view)
        tableView.tableFooterView = UIView(frame: .zero)
        if content != nil && exam == nil {
            exam = content.exam
        }
        UIUtils.setTableViewSeperatorInset(tableView, size: 15)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (attempts.isEmpty) {
            loadAttemptsWithProgress(url: content.attemptsUrl!)
        }
        tableView.reloadData()
    }
    
    func loadAttemptsWithProgress(url: String) {
        tableView.tableFooterView = UIView(frame: .zero)
        activityIndicator = UIUtils.initActivityIndicator(parentView: view)
        activityIndicator.startAnimating()
        loadAttempts(url: url)
    }
    
    func loadAttempts(url: String) {
        TPApiClient.getListItems(
            endpointProvider: TPEndpointProvider(.loadAttempts, url: url),
            completion: {
                testpressResponse, error in
                if let error = error {
                    debugPrint(error.message ?? "No error")
                    debugPrint(error.kind)
                    var retryButtonText: String?
                    var retryHandler: (() -> Void)?
                    if error.kind == .network {
                        retryButtonText = Strings.TRY_AGAIN
                        retryHandler = {
                            self.emptyView.hide()
                            self.loadAttemptsWithProgress(url: url)
                        }
                    }
                    if self.activityIndicator.isAnimating {
                        self.activityIndicator.stopAnimating()
                    }
                    let (image, title, description) = error.getDisplayInfo()
                    self.emptyView.show(image: image, title: title, description: description,
                                        retryButtonText: retryButtonText,
                                        retryHandler: retryHandler)
                    
                    return
                }
                
                self.attempts.append(contentsOf: testpressResponse!.results)
                if !(testpressResponse!.next.isEmpty) {
                    self.loadAttempts(url: testpressResponse!.next)
                } else {
                    self.displayAttemptsList()
                }
        }, type: ContentAttempt.self)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attempts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
        UITableViewCell {
            
            if attempts.count <= indexPath.row {
                // Needed to prevent index out of bound execption when dismiss view controller while
                // table view is scrolling
                return UITableViewCell()
            }
            let attempt = attempts[indexPath.row].assessment!
            var cellIdentifier: String
            if attempt.state == Constants.STATE_RUNNING {
                cellIdentifier = Constants.PAUSED_ATTEMPT_TABLE_VIEW_CELL
            } else {
                cellIdentifier = Constants.COMPLETED_ATTEMPT_TABLE_VIEW_CELL
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
                as! AttemptsTableViewCell
            
            cell.initCell(attempt: attempt, parentViewController: self)
            return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contentAttempt = attempts[indexPath.row]
        if contentAttempt.assessment.state == Constants.STATE_RUNNING {
            showStartExamScreen(contentAttempt: contentAttempt)
        } else {
            showTestReport(contentAttempt: contentAttempt)
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) ->
        UIView? {
                
            return tableView.dequeueReusableCell(withIdentifier: "AttemptsListHeader")!
    }
    
    func getFooter() -> UIView? {
        // Clear existing paused attempts if exist
        pausedAttempts.removeAll()
        for attempt: ContentAttempt in attempts {
            if attempt.assessment.state == Constants.STATE_RUNNING {
                pausedAttempts.append(attempt);
            }
        }
        if canAttemptExam() {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContentAttemptFooterCell")
                as! ContentAttemptFooterCell
            
            cell.initCell(parentViewController: self)
            return cell
        }
        return UIView(frame: .zero)
    }
    
    private func displayAttemptsList() {
        tableView.reloadData()
        tableView.tableFooterView = getFooter()
        if (activityIndicator?.isAnimating)! {
            activityIndicator?.stopAnimating()
        }
    }
    
    private func canAttemptExam() -> Bool {
        // User can't retake an exam if retake disabled or max retake attemted or web only exam or
        // exam start date is future. If paused attempt exist, can resume it.
        if (exam.attemptsCount! == 0 || pausedAttempts.count != 0 ||
            ((exam.allowRetake!) && (attempts.count <= exam.maxRetakes! || exam.maxRetakes! < 0))) {
            
            if (exam.deviceAccessControl != nil && exam.deviceAccessControl == "web") {
                return false;
            } else {
                return exam.hasStarted()
            }
        }
        return false;
    }
    
    func showStartExamScreen(contentAttempt: ContentAttempt? = nil) {
        let storyboard = UIStoryboard(name: Constants.TEST_ENGINE, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier:
            Constants.START_EXAM_SCREEN_VIEW_CONTROLLER) as! StartExamScreenViewController
        
        viewController.content = content
        if contentAttempt != nil {
            viewController.contentAttempt = contentAttempt
        }
        showDetailViewController(viewController, sender: self)
    }
    
    func showTestReport(contentAttempt: ContentAttempt) {
        let storyboard = UIStoryboard(name: Constants.EXAM_REVIEW_STORYBOARD, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier:
            Constants.TEST_REPORT_VIEW_CONTROLLER) as! TestReportViewController
        
        viewController.exam = self.exam!
        viewController.attempt = contentAttempt.assessment
        showDetailViewController(viewController, sender: self)
    }
    
    override func viewDidLayoutSubviews() {
        activityIndicator?.frame = view.frame
    }
    
}

class ContentAttemptFooterCell: UITableViewCell {
    
    @IBOutlet weak var startButton: UIButton!
    
    var parentViewController: ContentExamAttemptsTableViewController!
    
    func initCell(parentViewController: ContentExamAttemptsTableViewController) {
        self.parentViewController = parentViewController
        if (parentViewController.pausedAttempts.isEmpty) {
            startButton.setTitle("RETAKE", for: .normal)
        } else {
            startButton.setTitle("RESUME", for: .normal)
        }
        UIUtils.setButtonDropShadow(startButton)
    }
    
    @IBAction func onClickStartButton(_ sender: UIButton) {
        parentViewController
            .showStartExamScreen(contentAttempt: parentViewController.pausedAttempts.last)
    }
}
