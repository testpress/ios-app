//
//  ActivityFeedTableViewController.swift
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

import TTGSnackbar
import UIKit

class ActivityFeedTableViewController: UITableViewController {
    
    var activityIndicator: UIActivityIndicatorView! // Progress bar
    var emptyView: EmptyView!
    var items = [ActivityFeed]()
    var pager: ActivityFeedPager
    var loadingItems: Bool = false
    var firstCallBack: Bool = true
    
    required init?(coder aDecoder: NSCoder) {
        self.pager = ActivityFeedPager()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator = UIUtils.initActivityIndicator(parentView: self.view)
        activityIndicator?.center = CGPoint(x: view.center.x, y: view.center.y - 150)
        // Set table view footer as progress spinner
        let pagingSpinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        pagingSpinner.startAnimating()
        pagingSpinner.color = Colors.getRGB(Colors.PRIMARY)
        pagingSpinner.hidesWhenStopped = true
        tableView.tableFooterView = pagingSpinner
        
        // Set table view backgroud
        emptyView = EmptyView.getInstance()
        tableView.backgroundView = emptyView
        emptyView.frame = tableView.frame
        
        UIUtils.setTableViewSeperatorInset(tableView, size: 10)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        if (items.isEmpty) {
            activityIndicator?.startAnimating()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (items.isEmpty || firstCallBack) {
            firstCallBack = false
            tableView.tableFooterView?.isHidden = true
            pager.reset()
            loadItems()
        }
    }
    
    func loadItems() {
        if loadingItems {
            return
        }
        loadingItems = true
        pager.next(completion: {
            items, error in
            if let error = error {
                debugPrint(error.message ?? "No error")
                debugPrint(error.kind)
                self.handleError(error)
                return
            }
            
            self.items = Array(items!.values)
            if self.items.count == 0 {
                self.setEmptyText()
            }
            self.onItemsLoaded()
            self.tableView.reloadData()
            if (self.activityIndicator?.isAnimating)! {
                self.activityIndicator?.stopAnimating()
            }
            self.tableView.tableFooterView?.isHidden = true
            self.loadingItems = false
        })
    }
    
    func handleError(_ error: TPError) {
        var retryHandler: (() -> Void)?
        if error.kind == .network {
            retryHandler = {
                self.activityIndicator?.startAnimating()
                self.loadItems()
            }
        }
        let (image, title, description) = error.getDisplayInfo()
        if (activityIndicator?.isAnimating)! {
            activityIndicator?.stopAnimating()
        }
        loadingItems = false
        if items.count == 0 {
            emptyView.setValues(image: image, title: title, description: description,
                                retryHandler: retryHandler)
        } else {
            TTGSnackbar(message: description, duration: .middle).show()
        }
        tableView.reloadData()
    }
    
    @objc func closeAlert(gesture: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if items.count == 0 {
            tableView.backgroundView?.isHidden = false
        } else {
            tableView.backgroundView?.isHidden = true
        }
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewCell(cellForRowAt: indexPath)
        // Load more items on scroll to bottom
        if indexPath.row >= (items.count - 4) && !loadingItems {
            if pager.hasMore {
                tableView.tableFooterView?.isHidden = false
                loadItems()
            } else {
                tableView.tableFooterView?.isHidden = true
            }
        }
        return cell
    }
    
    func tableViewCell(cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:
            Constants.ACTIVITY_FEED_TABLE_VIEW_CELL, for: indexPath) as! ActivityFeedTableViewCell
        
        cell.initCell(activityFeed: items[indexPath.row], viewController: self)
        return cell
    }
    
    func onItemsLoaded() {
        items = items.sorted(by: {
            FormatDate.compareDate(dateString1:  $0.timestamp, dateString2: $1.timestamp)
        })
    }
    
    func setEmptyText() {
        emptyView.setValues(image: Images.LearnFlatIcon.image, title: Strings.NO_ITEMS_EXIST,
                            description: Strings.NO_CONTENT_DESCRIPTION)
    }
    
    @IBAction func showProfileDetails(_ sender: UIBarButtonItem) {
        UIUtils.showProfileDetails(self)
    }
    
}
