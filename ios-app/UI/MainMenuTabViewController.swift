//
//  MainMenuTabViewController.swift
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
import Alamofire

class MainMenuTabViewController: UITabBarController {
    
    var instituteSettings: InstituteSettings!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStatusBarColor()
        instituteSettings = DBManager<InstituteSettings>().getResultsFromDB()[0]
        viewControllers?[5].tabBarItem.title = instituteSettings.postsLabel
        viewControllers?.remove(at: 7) // Access code
        if (!instituteSettings.forumEnabled) {
            viewControllers?.remove(at: 6)
        }
        
        if (!instituteSettings.postsEnabled) {
            viewControllers?.remove(at: 5)
        }
        
        if (!instituteSettings.coursesEnableGamification) {
            viewControllers?.remove(at: 4)
        }
        
        if (instituteSettings.showGameFrontend) {
            viewControllers?.remove(at: 3) // Exams list
            
        } else {
            viewControllers?.remove(at: 2)
        }
        
        if (!instituteSettings.activityFeedEnabled) {
            viewControllers?.remove(at: 1)
        }


        
        let storyboard = UIStoryboard(name: Constants.MAIN_STORYBOARD, bundle: nil)
        if let secondViewController = storyboard.instantiateViewController(
        withIdentifier: "CoursesTableViewController") as? CoursesTableViewController {
            secondViewController.tags = ["exams"]
            let navgitaionController1 = UINavigationController(rootViewController: secondViewController)
            navgitaionController1.title = "Tests"
            navgitaionController1.tabBarItem.image = Images.BookIcon.image
            self.viewControllers?.insert(navgitaionController1, at: 1)
        }
        
        if let thirdViewController = storyboard.instantiateViewController(
        withIdentifier: "CoursesTableViewController") as? CoursesTableViewController {
            thirdViewController.tags = ["classes"]
            let navgitaionController1 = UINavigationController(rootViewController: thirdViewController)
            navgitaionController1.title = "Classes"
            navgitaionController1.tabBarItem.image = Images.ExamIconHome.image
            self.viewControllers?.insert(navgitaionController1, at: 2)
        }
        
        showAnalytics()
        if (UserDefaults.standard.string(forKey: Constants.REGISTER_DEVICE_TOKEN) == "true") {
            let deviceToken = UserDefaults.standard.string(forKey: Constants.DEVICE_TOKEN)
            let fcmToken = UserDefaults.standard.string(forKey: Constants.FCM_TOKEN)
            let parameters: Parameters = [
                "device_id": deviceToken!,
                "registration_id": fcmToken!,
                "platform": "ios"
            ]
            TPApiClient.apiCall(endpointProvider: TPEndpointProvider(.registerDevice), parameters: parameters,completion: { _, _ in})
        }
    }
    
    func showAnalytics() {
        let examStoryboard = UIStoryboard(name: Constants.EXAM_REVIEW_STORYBOARD, bundle: nil)
        let subjectAnalyticsViewController = examStoryboard.instantiateViewController(
            withIdentifier: Constants.SUBJECT_ANALYTICS_TAB_VIEW_CONTROLLER)
            as! SubjectAnalyticsTabViewController
        let navgitaionController2 = UINavigationController(rootViewController: subjectAnalyticsViewController)
        subjectAnalyticsViewController.shouldHideNavbar = true
        navgitaionController2.title = "Analytics"
        navgitaionController2.tabBarItem.image = Images.AnalyticsIcon.image

        self.viewControllers?.insert(navgitaionController2, at: 3)
    }
}
