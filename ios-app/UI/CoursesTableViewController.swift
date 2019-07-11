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
    
    var customPager: TPBasePager<Course>
    var customItems = [CustomCourse]()
    let babapedia = CustomCourse(title: "Babapedia 2019", url: "https://babapedia2019.iasbaba.com",
                                 image: Images.GlobalLearning.image)
    let babapedia2020 = CustomCourse(title: "Babapedia 2020", url: "https://babapedia2020.iasbaba.com",
                                 image: Images.BookIcon.image)
    
    let valueAddedNotes = CustomCourse(title: "ILP 2019",
                                       url: "https://ilp2019.iasbaba.com/",
                                       image: Images.NotesMenuIcon.image)
    
    let ILP2020 = CustomCourse(title: "ILP 2020",
                                       url: "https://ilp2020.iasbaba.com/",
                                       image: Images.PaperAirplaneIcon.image)
    
    required init?(coder aDecoder: NSCoder) {
        debugPrint(Realm.Configuration.defaultConfiguration.fileURL!)
        customPager = CoursePager()
        customItems.append(babapedia)
        customItems.append(babapedia2020)
        customItems.append(valueAddedNotes)
        customItems.append(ILP2020)
        super.init(pager: customPager, coder: aDecoder)
    }
    
    override func getItemsFromDb() -> [Course] {
        return DBManager<Course>()
            .getItemsFromDB(filteredBy: "active = true", byKeyPath: "order")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
        super.viewDidAppear(animated)
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
                self.onLoadFinished(items: self.getItemsFromDb())

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
