//
//  TestMainMenuTabViewController.swift
//  ios-appTests
//
//  Copyright © 2019 Testpress. All rights reserved.
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

import XCTest
@testable import ios_app

class TestMainMenuTabViewController: XCTestCase {
    
    var controller: MainMenuTabViewController!
    
    override func setUp() {
        super.setUp()
        TestUtils.saveInstituteSettings(TestUtils.getInstituteSettings())
        controller = viewController()
        controller.loadViewIfNeeded()
    }
    
    func viewController() -> MainMenuTabViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(
            withIdentifier: Constants.TAB_VIEW_CONTROLLER) as! MainMenuTabViewController
    }
    
    func testVisibilityOfActivityFeed() {
        /*
         Activity Feed's visibility should be determined using institute settings
         */
        var vc = controller.viewControllers?[0] as? UINavigationController
        XCTAssertNil(vc?.viewControllers[0].isKind(of:ActivityFeedTableViewController.self))
        
        TestUtils.saveInstituteSettings(TestUtils.getInstituteSettings(activityFeedEnabled: true))
        controller = viewController()
        vc = controller.viewControllers?[0] as? UINavigationController

        XCTAssertTrue(vc?.viewControllers[0].isKind(of:ActivityFeedTableViewController.self) ?? false)
    }
    
}
