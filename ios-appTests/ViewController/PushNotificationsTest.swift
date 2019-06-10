//
//  ios_appTests.swift
//  ios-appTests
//
//  Created by Vignesh on 22/03/2017.
//  Copyright © 2017 Testpress. All rights reserved.
//

import XCTest
@testable import ios_app

class PushNotificationsTest: XCTestCase {
    
    let appDelegate = AppDelegate();
    private let application = UIApplication.shared
    
    override func setUp() {
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testDidRegisterForRemoteNotificationsWithDeviceToken() {
        /*
         This tests whether device token is getting stored or not on register remote notifications.
         */
        let input = "token"
        let token = input.data(using: .utf8)!
        let deviceTokenString = token.reduce("", {$0 + String(format: "%02X", $1)})
        appDelegate.application(application, didRegisterForRemoteNotificationsWithDeviceToken: token)
        XCTAssertEqual(UserDefaults.standard.string(forKey: Constants.DEVICE_TOKEN)!, deviceTokenString)
        XCTAssertEqual(UserDefaults.standard.string(forKey: Constants.REGISTER_DEVICE_TOKEN), "true")
    }
    
    func testTopController() {
        /*
         This tests whether top most view controller.
         */
        XCTAssertNotNil(UIApplication.topViewController())
    }
    
}
