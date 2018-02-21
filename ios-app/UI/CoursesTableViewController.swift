//
//  CoursesTableViewController.swift
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

import RealmSwift
import UIKit

class CoursesTableViewController: BaseDBViewController<Course> {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(pager: getPager(), coder: aDecoder)
    }
    
    func getPager() -> CoursePager {
        debugPrint(Realm.Configuration.defaultConfiguration.fileURL!)
        return CoursePager()
    }
    
    override func getItemsFromDb() -> [Course] {
        return DBManager<Course>()
            .getItemsFromDB(filteredBy: "active = true", byKeyPath: "order")
    }
    
    override func loadItems() {
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
            
            if self.pager.hasMore {
                self.loadingItems = false
                self.loadItems()
            } else {
                let items = Array(items!.values)
                DBManager<Course>().deleteAllFromDatabase() // Delete previous items
                DBManager<Course>().addData(objects: items)
                self.items = self.getItemsFromDb()
                if self.items.count == 0 {
                    self.setEmptyText()
                }
                self.delegate?.onItemsLoaded()
                self.tableView.reloadData()
                if self.activityIndicator.isAnimating {
                    self.activityIndicator.stopAnimating()
                }
                self.tableView.tableFooterView?.isHidden = true
                self.loadingItems = false
            }
        })
    }
    
    // MARK: - Table view data source
    override func tableViewCell(cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.COURSE_LIST_VIEW_CELL, for: indexPath) as! CourseTableViewCell

        cell.initCell(items[indexPath.row], viewController: self)
        return cell
    }
    
    override func setEmptyText() {
        emptyView.setValues(image: Images.LearnFlatIcon.image, title: Strings.NO_COURSES,
                            description: Strings.NO_COURSE_DESCRIPTION)
    }
    
    @IBAction func showProfileDetails(_ sender: UIBarButtonItem) {
        UIUtils.showProfileDetails(self)
    }
    
}
