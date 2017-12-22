//
//  ProgressCardViewController.swift
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

class ProgressCardViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentStackView: UIStackView!
    
    var activityIndicator: UIActivityIndicatorView!
    var emptyView: EmptyView!
    var userId: Int!
    var loading: Bool = false
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        contentView.isHidden = true
        emptyView = EmptyView.getInstance(parentView: scrollView)
        emptyView.parentView = view
        activityIndicator = UIUtils.initActivityIndicator(parentView: scrollView)
        activityIndicator.frame = view.frame
        activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y - 50)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if userId == nil && !loading {
            if userDefaults.bool(forKey: Constants.TESTPRESS_USER_ID) == false {
                getProfile()
            } else {
                userId = userDefaults.integer(forKey: Constants.TESTPRESS_USER_ID)
                displayProgressCardItems(userId: userId)
            }
        }
    }
    
    func getProfile() {
        loading = true
        activityIndicator.startAnimating()
        emptyView.hide()
        TPApiClient.getProfile(
            endpointProvider: TPEndpointProvider(.getProfile),
            completion: {
                user, error in
                if let error = error {
                    debugPrint(error.message ?? "No error")
                    debugPrint(error.kind)
                    var retryHandler: (() -> Void)?
                    if error.kind == .network {
                        retryHandler = {
                            self.getProfile()
                        }
                    }
                    if (self.activityIndicator?.isAnimating)! {
                        self.activityIndicator?.stopAnimating()
                    }
                    let (image, title, description) = error.getDisplayInfo()
                    self.emptyView.show(image: image, title: title, description: description,
                                        retryHandler: retryHandler)
                    
                    self.loading = false
                    print("Display empty view")
                    return
                }
                
                self.userDefaults.set(user!.id, forKey: Constants.TESTPRESS_USER_ID)
                self.userDefaults.synchronize()
                self.activityIndicator?.stopAnimating()
                self.displayProgressCardItems(userId: user!.id)
        })
    }
    
    func displayProgressCardItems(userId: Int) {
        self.userId = userId
        loading = false
        contentView.isHidden = false
    }
    
    func showWebView(title: String, urlPath: String) {
        let viewController = storyboard?.instantiateViewController(withIdentifier:
            Constants.WEB_VIEW_CONTROLLER) as! WebViewController
        
        let url = "https://extelacademy.com/students1617/cgi_api_testpress.php?testpress_id="
            + "\(userId)&report_type="
        
        viewController.url = url + urlPath
        viewController.title = title
        present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func onClickSchedule() {
        showWebView(title: "Schedule", urlPath: "my_schedule")
    }
    
    @IBAction func onClickAttendance() {
        showWebView(title: "Attendance", urlPath: "my_attendance")
    }
    
    @IBAction func onClickTestMark() {
        showWebView(title: "Test Mark", urlPath: "my_test_mark")
    }
    
    @IBAction func onClickReview() {
        showWebView(title: "Review", urlPath: "my_review")
    }
    
    override func viewDidLayoutSubviews() {
        // Set scroll view content height to support the scroll
        let height = contentStackView.frame.size.height
        contentViewHeightConstraint.constant = height
        scrollView.contentSize.height = height
        contentView.layoutIfNeeded()
    }
}
