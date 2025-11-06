//
//  PostCategoriesTableViewController.swift
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

import ObjectMapper
import UIKit
import CourseKit

protocol PostCategoryDelegate {
    func onLoadedCategories(_ categories: [CourseKit.Category])
    func onError(_ error: TPError)
    func onEmptyCategories()
    func showCategories()
}

class PostCategoriesTableViewController: BaseTableViewController<CourseKit.Category>, BaseTableViewDelegate {
    
    var pager: CategoryPager!
    var postCategoryDelegate: PostCategoryDelegate?
    var categories = [CourseKit.Category]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pager = CategoryPager()
        tableViewDelegate = self
        tableView.frame.size.height = 156
        activityIndicator?.center = CGPoint(x: view.center.x, y: tableView.center.y)
        tableView.reloadData()
        if (items.isEmpty) {
            activityIndicator?.startAnimating()
            tableViewDelegate.loadItems()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {        
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    func loadItems() {
        pager.next(completion: {
            items, error in
            if let error = error {
                debugPrint(error.message ?? "No error")
                debugPrint(error.kind)
                self.handleError(error)
                self.postCategoryDelegate?.onError(error)
                return
            }
            
            if self.pager.hasMore {
                self.loadItems()
            } else {
                self.categories = Array(items!.values)
                self.postCategoryDelegate?.onLoadedCategories(self.categories)
                var starred = [CourseKit.Category]()
                for category in self.categories {
                    if category.is_starred {
                        starred.append(category)
                    }
                }
                self.items = starred
                if self.items.count == 0 {
                    self.setEmptyText()
                    self.postCategoryDelegate?.onEmptyCategories()
                } else {
                    self.postCategoryDelegate?.showCategories()
                }
                self.onLoadFinished(items: self.items)
            }
        })
    }
    
    // MARK: - Table view data source
    override func tableViewCell(cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.POST_CATEGORIES_TABLE_VIEW_CELL,
            for: indexPath
            ) as! PostCategoriesTableViewCell
        
        cell.initCell(items[indexPath.row], viewController: self)
        return cell
    }
    
}
