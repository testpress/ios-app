//
//  TestCourseViewController.swift
//  ios-appTests
//
//  Created by Karthik raja on 6/7/19.
//  Copyright © 2019 Testpress. All rights reserved.
//

import XCTest
import Hippolyte
@testable import ios_app

class TestCourseViewController: XCTestCase {
    
    var courses = [Course]()
    var controller: CoursesTableViewController!
    
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: Constants.MAIN_STORYBOARD, bundle: nil)
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "CoursesTableViewController") as? CoursesTableViewController else {
                return XCTFail("Could not instantiate ViewController from main storyboard")
        }
        controller = vc
        controller.loadViewIfNeeded()
        controller.tableView.reloadData()
        let window = UIWindow()
        window.rootViewController = controller
        window.makeKeyAndVisible()
    }
    
    func getCourse(id: Int? = nil, url: String? = nil, title: String? = nil, slug: String? = nil, external_content_link: String? = nil, external_link_label: String? = nil) -> Course {
        let course = Course()
        course.id = id ?? Int.random(in: 0 ... 100)
        course.url = url ?? "http://google.com"
        course.title = title ?? "Course - \(course.id)"
        course.modified = "2019-06-07T05:40:55.541270Z"
        course.contentsUrl = "https://lmsdemo.testpress.in/api/v2.2.1/courses/1/contents/"
        course.chaptersUrl = "https://lmsdemo.testpress.in/api/v2.2.1/courses/1/chapters/"
        course.slug = slug ?? "course-\(course.id)"
        course.external_content_link = external_content_link ?? "http://google.com"
        course.external_link_label = external_link_label ?? "Register Here"
        return course
    }

    func testExternalLinkLabelVisibility() {
        /*
         External link should be visible if course contains external link
         */
        let course = getCourse()
        let cell = controller.tableView.dequeueReusableCell(
            withIdentifier: Constants.COURSE_LIST_VIEW_CELL, for: IndexPath(row: 0, section: 0)) as! CourseTableViewCell
        cell.initCell(course, viewController: controller)

        XCTAssertFalse(cell.externalLinkLabel.isHidden)
    }
    
    func testViewControllerForExternalLinkClick() {
        /*
         On clicking course with external link, web view should be displayed
         */
        let course = getCourse()
        let cell = controller.tableView.dequeueReusableCell(
            withIdentifier: Constants.COURSE_LIST_VIEW_CELL, for: IndexPath(row: 0, section: 0)) as! CourseTableViewCell
        cell.initCell(course, viewController: controller)
        cell.onItemClick()
        
        XCTAssertTrue((controller.presentedViewController?.isKind(of: WebViewController.self))!)
    }
    
    func testExternalLinkLabelVisibilityWithoutExternalLink() {
        /*
         External link should be hidden if course does not contains external link
         */
        let course = getCourse(external_content_link: "")
        let cell = controller.tableView.dequeueReusableCell(
            withIdentifier: Constants.COURSE_LIST_VIEW_CELL, for: IndexPath(row: 0, section: 0)) as! CourseTableViewCell
        cell.initCell(course, viewController: controller)
        
        XCTAssertTrue(cell.externalLinkLabel.isHidden)
    }
}
