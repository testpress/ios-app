//
//  BasePagedTableViewController.swift
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
import ObjectMapper
import CourseKit

// Base Paged TableViewController for V4 API's
class BasePagedTableViewController<T: TestpressModel, L: TestpressModel>
    : BaseTableViewController<L>, BaseTableViewDelegate {
    
    var pager: BasePager<T, L>
    var loadingItems: Bool = false
    
    init(pager: BasePager<T, L>, coder aDecoder: NSCoder? = nil) {
        self.pager = pager
        // Support table cell view from both xib & storyboard
        if aDecoder != nil {
            super.init(coder: aDecoder!)!
        } else {
            super.init(style: .plain)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set table view footer as progress spinner
        let pagingSpinner = UIActivityIndicatorView(style: .gray)
        pagingSpinner.startAnimating()
        pagingSpinner.color = Colors.getRGB(Colors.PRIMARY)
        pagingSpinner.hidesWhenStopped = true
        tableView.tableFooterView = pagingSpinner
        
        tableViewDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (items.isEmpty) {
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
                self.loadingItems = false
                self.handleError(error)
                return
            }
            
            self.onLoadFinished(items: Array(items!.values))
        })
    }
    
    override func onLoadFinished(items: [L]) {
        if items.count == 0 {
            setEmptyText()
        }
        super.onLoadFinished(items: items)
        self.tableView.tableFooterView?.isHidden = true
        self.loadingItems = false
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
    
    override func refreshWithProgress() {
        pager.reset()
        super.refreshWithProgress()
    }
    
}
