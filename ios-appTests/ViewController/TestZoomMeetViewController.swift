//
//  TestZoomMeetViewController.swift
//  ios-appTests
//
//  Created by Karthik on 01/10/20.
//  Copyright © 2020 Testpress. All rights reserved.
//

import XCTest
import MobileRTC
import MobileCoreServices

@testable import ios_app

class TestZoomMeetViewController: XCTestCase {
    let appDelegate = AppDelegate()
    
    var controller: ZoomMeetViewController!
    
    override func setUp() {
        let storyboard = UIStoryboard(name: Constants.CHAPTER_CONTENT_STORYBOARD, bundle: nil)
        controller = storyboard.instantiateViewController(withIdentifier:
            Constants.ZOOM_MEET_VIEW_CONTROLLER) as? ZoomMeetViewController
        controller.accessToken = "12323"
        controller.meetingNumber = "1324"
        controller.password = "abcd"
        controller.meetingTitle = "Hello"
        
        let window = UIWindow()
        window.rootViewController = controller
        window.makeKeyAndVisible()
    }

    func testEmptyViewShouldNotBeNil() {
        XCTAssertNotNil(controller.emptyView)
    }
    
    func testLoadingShouldBeDisplayedInitially() {
        XCTAssertTrue(controller.activityIndicator.isAnimating)
    }

    func testBackButtonPressShouldGoToMainDashboard() {
        controller.back(controller.emptyView)
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        
        XCTAssertTrue(appDelegate.window!.rootViewController!.isKind(of: MainMenuTabViewController.self))
    }
    
    func testPreviousPageShouldBeOpenedInCaseNoMeetingIsRunning() {
        controller.prepareAndJoin()
        controller.onMeetingStateChange(MobileRTCMeetingState_Idle)
        
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        XCTAssertTrue(appDelegate.window!.rootViewController!.isKind(of: MainMenuTabViewController.self))
    }
    
    func testErrorScreenShouldBeDisplayedInCaseMeetingError() {
        controller.onMeetingError(MobileRTCMeetError_NetworkError, message: "Network Error")
        
        XCTAssertFalse(controller.emptyView.isHidden)
        XCTAssertEqual(controller.emptyView.emptyViewTitle.text, "Error Occurred")
        XCTAssertEqual(controller.emptyView.emptyViewDescription.text, "Network Error")
    }
    
    func testErrorScreenShouldNotBeDisplayedOnSuccessfullyJoiningMeeting() {
        controller.onMeetingError(MobileRTCMeetError_Success, message: "Joined Successfully")

        XCTAssertTrue(controller.emptyView.isHidden)
    }
}
