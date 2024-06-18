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

class CoursesTableViewController: BaseDBTableViewController<Course> {
    
    var tags: [String] = []
    @IBOutlet weak var customTestIcon: UIBarButtonItem!
    var instituteSettings: InstituteSettings?
    
    required init?(coder aDecoder: NSCoder) {
        debugPrint(Realm.Configuration.defaultConfiguration.fileURL!)
        super.init(pager: CoursePager(), coder: aDecoder)
    }
    
    override func getItemsFromDb() -> [Course] {
        var courses = DBManager<Course>()
            .getItemsFromDB(filteredBy: "active = true", byKeyPath: "order")
        
        if tags.count > 0 {
            courses = courses.filter { (course: Course) in
                !Set(course.tags).isDisjoint(with: tags)
            }
        }
        return courses
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
        super.viewDidAppear(animated)
        instituteSettings = DBManager<InstituteSettings>().getResultsFromDB()[0]
        showOrHideCustomTestIcon()
    }
    
    func showOrHideCustomTestIcon(){
        if ((instituteSettings?.enableCustomTest ?? false)) {
            customTestIcon.isEnabled = true
            customTestIcon.tintColor = nil
        } else {
            customTestIcon.isEnabled = false
            customTestIcon.tintColor = UIColor.clear
        }
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

        cell.initCell(items[indexPath.row], viewController: self)
        return cell
    }
    
    override func setEmptyText() {
        emptyView.setValues(image: Images.LearnFlatIcon.image, title: Strings.NO_COURSES,
                            description: Strings.NO_COURSE_DESCRIPTION)
    }
    
    @IBAction func showCustomTestPage(_ sender: UIBarButtonItem) {
        showCustomTestWebviewPage(self)
    }
    
    func showCustomTestWebviewPage(_ viewController: UIViewController) {
        let secondViewController = CustomTestGenerationViewController()
        secondViewController.url = "&next=/courses/custom_test_generation/?"+constrictQueryParamForAvailableCourses()+"%26testpress_app=ios"
        secondViewController.useWebviewNavigation = true
        secondViewController.useSSOLogin = true
        secondViewController.shouldOpenLinksWithinWebview = true
        secondViewController.title = "Custom Module"
        secondViewController.displayNavbar = true
        secondViewController.modalPresentationStyle = .fullScreen
        viewController.present(secondViewController, animated: true)
    }
    
    func constrictQueryParamForAvailableCourses() -> String {
        var queryParam = ""
        for course in getItemsFromDb() {
            queryParam += "course_id=\(course.id)%26"
        }
        return queryParam
    }
    
}
