//
//  TestShareToUnlockViewController.swift
//  ios-appTests
//
//  Created by Karthik on 23/03/20.
//  Copyright © 2020 Testpress. All rights reserved.
//

import Foundation
import XCTest


@testable import ios_app

class TestShareToUnlockViewController: XCTestCase {
    let appDelegate = AppDelegate();
    var controller: ShareToUnlockViewController?
    var onShareCompletionHandler: (() -> Void)?

    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: Constants.MAIN_STORYBOARD, bundle: nil)
        controller = storyboard.instantiateViewController(withIdentifier:
            Constants.SHARE_TO_UNLOCK_VIEW_CONTROLLER) as? ShareToUnlockViewController
        controller?.shareText = "Share to other users"
        controller?.onShareCompletion = onShareCompletionHandler
        let window = UIWindow()
        window.rootViewController = controller
        window.makeKeyAndVisible()
        controller?.viewDidLoad()
    }
    
    func testSample() {
        controller?.share(controller?.shareButton)
        print("--------------------------------")
        print(UIApplication.topViewController())
    }
}
