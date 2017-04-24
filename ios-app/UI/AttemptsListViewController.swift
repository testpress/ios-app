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

class AttemptsListViewController: UITableViewController {
    
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    
    static let HEADER_VIEW_HEIGHT: CGFloat = 65
    
    var activityIndicator: UIActivityIndicatorView? // Progress bar
    var exam: Exam!
    var attempts: [Attempt] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarItem.title = exam.title
        // Set navigation bar below the status bar.
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        tableView.contentInset = UIEdgeInsets(top: statusBarHeight, left: 0, bottom: 0, right: 0)
        
        if (attempts.isEmpty) {
            activityIndicator = UIUtils.initActivityIndicator(parentView: self.view)
            activityIndicator?.center = CGPoint(x: view.center.x, y: view.center.y)
            activityIndicator?.startAnimating()
            loadAttempts(url: exam.attemptsUrl!)
        }
        tableView.tableFooterView = UIView(frame: .zero)
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
                    self.tableView.reloadData()
                    if (self.activityIndicator?.isAnimating)! {
                        self.activityIndicator?.stopAnimating()
                    }
                }
            }
        )
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attempts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableCell(withIdentifier: "AttemptsListHeader")!
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return AttemptsListViewController.HEADER_VIEW_HEIGHT
    }
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

}
