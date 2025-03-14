//
//  BaseTableViewController.swift
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
import ObjectMapper
import XLPagerTabStrip

public protocol BaseTableViewDelegate {
    func loadItems()
}

open class BaseTableViewController<T: Mappable>: UITableViewController {
    
    public var activityIndicator: UIActivityIndicatorView! // Progress bar
    public var emptyView: EmptyView!
    public var items = [T]()
    public var tableViewDelegate: BaseTableViewDelegate!
    public var useInterfaceBuilderSeperatorInset = false
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
        }
        
        activityIndicator = UIUtils.initActivityIndicator(parentView: self.view)
        activityIndicator?.center = CGPoint(x: view.center.x, y: view.center.y - 150)
        
        // Set table view backgroud
        emptyView = EmptyView.getInstance()
        tableView.backgroundView = emptyView
        emptyView.frame = tableView.frame
        
        if !useInterfaceBuilderSeperatorInset {
            UIUtils.setTableViewSeperatorInset(tableView, size: 15)
        }
        tableView.tableFooterView = UIView()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        if (items.isEmpty) {
            activityIndicator?.startAnimating()
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (items.isEmpty) {
            tableViewDelegate.loadItems()
        }
    }
    
    public func onLoadFinished(items: [T]) {
        self.items = items
        self.tableView.reloadData()
        if (self.activityIndicator?.isAnimating)! {
            self.activityIndicator?.stopAnimating()
        }
    }
    
    open func handleError(_ error: TPError) {
        var retryHandler: (() -> Void)?
        if error.kind == .network {
            retryHandler = {
                self.activityIndicator?.startAnimating()
                self.tableViewDelegate.loadItems()
            }
        }
        let (image, title, description) = error.getDisplayInfo()
        if (activityIndicator?.isAnimating)! {
            activityIndicator?.stopAnimating()
        }
        if items.count == 0 {
            emptyView.setValues(image: image, title: title, description: description,
                                retryHandler: retryHandler)
        } else {
            TTGSnackbar(message: description, duration: .middle).show()
        }
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    open override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if items.count == 0 {
            tableView.backgroundView?.isHidden = false
        } else {
            tableView.backgroundView?.isHidden = true
        }
        return items.count
    }
    
    open override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return tableViewCell(cellForRowAt: indexPath)
    }
    
    open func tableViewCell(cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    open func refreshWithProgress() {
        activityIndicator?.startAnimating()
        tableViewDelegate.loadItems()
    }
    
    open func setEmptyText() {
        emptyView.setValues(image: Images.LearnFlatIcon.image, description: Strings.NO_ITEMS_EXIST)
    }
    
}
