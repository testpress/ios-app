//
//  AttemptsListViewController.swift
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

class AttemptsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    @IBOutlet weak var startButtonLayout: UIView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomShadowView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    static let HEADER_VIEW_HEIGHT: CGFloat = 45
    
    var activityIndicator: UIActivityIndicatorView? // Progress bar
    var exam: Exam!
    var attempts: [Attempt] = []
    var pausedAttempts: [Attempt] = []
    
    override func viewDidLoad() {
        navigationBarItem.title = exam.title
        startButtonLayout.isHidden = true
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (attempts.isEmpty) {
            activityIndicator = UIUtils.initActivityIndicator(parentView: contentView)
            activityIndicator?.center = CGPoint(x: contentView.center.x, y: contentView.center.y)
            activityIndicator?.startAnimating()
            loadAttempts(url: exam.attemptsUrl!)
        }
        tableView.reloadData()
    }
    
    func loadAttempts(url: String) {
        TPApiClient.loadAttempts(
            endpointProvider: TPEndpointProvider(.loadAttempts, url: url),
            completion: {
                testpressResponse, error in
                if let error = error {
                    print(error.message ?? "No error")
                    print(error.kind)
                    switch (error.kind) {
                    case .network:
                        print("Internet Unavailable")
                    case .unauthenticated:
                        print("Authorization Required")
                    case .http:
                        print("HTTP error occured")
                    default:
                        print("Unexpected")
                    }
                    return
                }
                
                self.attempts.append(contentsOf: testpressResponse!.results)
                if !(testpressResponse!.next.isEmpty) {
                    self.loadAttempts(url: testpressResponse!.next)
                } else {
                    self.displayAttemptsList()
                }
            }
        )
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attempts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if attempts.count <= indexPath.row {
            // Needed to prevent index out of bound execption when dismiss view controller while
            // table view is scrolling
            return UITableViewCell()
        }
        let attempt = attempts[indexPath.row]
        var cellIdentifier: String
        if attempt.state == Constants.STATE_RUNNING {
            cellIdentifier = Constants.PAUSED_ATTEMPT_TABLE_VIEW_CELL
        } else {
            cellIdentifier = Constants.COMPLETED_ATTEMPT_TABLE_VIEW_CELL
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            as! AttemptsTableViewCell
        
        cell.initCell(exam: exam, attempt: attempts[indexPath.row], parentViewController: self)
        
        // Customise items seperator
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
        cell.layoutMargins = UIEdgeInsets.zero;
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let attempt = attempts[indexPath.row]
        if attempt.state == Constants.STATE_RUNNING {
            showStartExamScreen(attempt: attempt)
        } else {
            showTestReport(attempt: attempt)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableCell(withIdentifier: "AttemptsListHeader")!
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return AttemptsListViewController.HEADER_VIEW_HEIGHT
    }
    
    @IBAction func onClickStartButton(_ sender: UIButton) {
        if pausedAttempts.isEmpty {
            showStartExamScreen()
        } else {
            showStartExamScreen(attempt: pausedAttempts.last)
        }
    }
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    private func displayAttemptsList() {
        tableView.reloadData()
        if canAttemptExam() {
            if exam.pausedAttemptsCount! > 0 {
                for attempt: Attempt in attempts {
                    if attempt.state == Constants.STATE_RUNNING {
                        pausedAttempts.append(attempt);
                    }
                }
            }
            if (pausedAttempts.isEmpty) {
                startButton.setTitle("RETAKE", for: .normal)
            } else {
               startButton.setTitle("RESUME", for: .normal)
            }
            startButtonLayout.isHidden = false
        } else {
            startButtonLayout.isHidden = true
        }
        if (activityIndicator?.isAnimating)! {
            activityIndicator?.stopAnimating()
        }
    }
    
    private func canAttemptExam() -> Bool {
        // User can't retake an exam if retake disabled or max retake attemted or web only exam or
        // exam start date is future. If paused attempt exist, can resume it.
        if (exam.attemptsCount! == 0 || exam.pausedAttemptsCount! != 0 ||
            ((exam.allowRetake!) &&
                (exam.attemptsCount! <= exam.maxRetakes! ||
                    exam.maxRetakes! < 0))) {
            
            if (exam.deviceAccessControl != nil && exam.deviceAccessControl == "web") {
                return false;
            } else {
                return exam.hasStarted()
            }
        }
        return false;
    }
    
    func showStartExamScreen(attempt: Attempt? = nil) {
        let storyboard = UIStoryboard(name: Constants.TEST_ENGINE, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier:
            Constants.START_EXAM_SCREEN_VIEW_CONTROLLER) as! StartExamScreenViewController
        viewController.exam = self.exam!
        if attempt != nil {
            viewController.attempt = attempt
        }
        showDetailViewController(viewController, sender: self)
    }
    
    func showTestReport(attempt: Attempt) {
        let storyboard = UIStoryboard(name: Constants.TEST_ENGINE, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier:
            Constants.TEST_REPORT_VIEW_CONTROLLER) as! TestReportViewController
        viewController.exam = self.exam!
        viewController.attempt = attempt
        showDetailViewController(viewController, sender: self)
    }
    
    override func viewDidLayoutSubviews() {
        // Set frames of the view here to support both portrait & landscape view
        // Add gradient shadow layer to the shadow container view
        let bottomGradient = CAGradientLayer()
        bottomGradient.frame = bottomShadowView.bounds
        bottomGradient.colors = [UIColor.white.cgColor, UIColor.black.cgColor]
        bottomShadowView.layer.insertSublayer(bottomGradient, at: 0)

        activityIndicator?.frame = contentView.frame
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)?) {
        super.dismiss(animated: flag, completion:completion)
        // Clear the attempts when user return from the test engine
        // This will cause the attempts to be load again on viewWillAppear
        attempts.removeAll()
    }

}
