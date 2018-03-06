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

class CoursesTableViewController: BaseTableViewController<Course> {
    
    var pager: TPBasePager<Course>
    var customItems = [CustomCourse]()
    let babapedia = CustomCourse(title: "Babapedia", url: "https://babapedia2018.iasbaba.com",
                                 image: Images.GlobalLearning.image)
    
    let valueAddedNotes = CustomCourse(title: "Value Add Notes",
                                       url: "https://ilp2018.iasbaba.com/value-add-notes",
                                       image: Images.NotesMenuIcon.image)
    
    let forum = CustomCourse(title: "Forum", url: "https://ilp2018.iasbaba.com/forum",
                             image: Images.ForumMenuIcon.image)
    
    required init?(coder aDecoder: NSCoder) {
        pager = CoursePager()
        super.init(coder: aDecoder)
        customItems.append(babapedia)
        customItems.append(valueAddedNotes)
        customItems.append(forum)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (items.isEmpty) {
            pager.reset()
            loadItems()
        }
    }
    
    func loadItems() {
        pager.next(completion: {
            items, error in
            
            if let error = error {
                debugPrint(error.message ?? "No error")
                debugPrint(error.kind)
                self.handleError(error)
                return
            }
            
            if self.pager.hasMore {
                self.loadItems()
            } else {
                self.items = Array(items!.values)
                if self.items.count == 0 {
                    self.setEmptyText()
                }
                self.onLoadFinished()
                self.tableView.tableFooterView?.isHidden = true
            }
        })
    }
    
    // MARK: - Table view data source
    override func tableViewCell(cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.COURSE_LIST_VIEW_CELL, for: indexPath) as! CourseTableViewCell

        cell.initCell(indexPath.row, viewController: self)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = super.tableView(tableView, numberOfRowsInSection: section)
        return count == 0 ? 0 : count + customItems.count
    }
    
    override func setEmptyText() {
        emptyView.setValues(image: Images.LearnFlatIcon.image, title: Strings.NO_COURSES,
                            description: Strings.NO_COURSE_DESCRIPTION)
    }
    
    @IBAction func showProfileDetails(_ sender: UIBarButtonItem) {
        UIUtils.showProfileDetails(self)
    }
    
}
