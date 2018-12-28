//
//  PhoneVerification.swift
//  ios-appTests
//
//  Created by Karthik on 28/12/18.
//  Copyright © 2018 Testpress. All rights reserved.
//

import XCTest

@testable import ios_app
import Hippolyte

class PhoneVerification: XCTestCase {

    let appDelegate = AppDelegate();
    var verifyPhoneViewController: VerifyPhoneViewController?

    override func setUp() {
        verifyPhoneViewController = VerifyPhoneViewController()
        verifyPhoneViewController!.initVerify(username:"demo", password: "password")
    }

    override func tearDown() {
        verifyPhoneViewController = nil
        Hippolyte.shared.stop()
    }

    func testUsernameAndPassword() {
        /*
            This tests username and password in the verifyPhoneViewController
         */
        XCTAssertEqual(verifyPhoneViewController!.username, "demo")
        XCTAssertEqual(verifyPhoneViewController!.password, "password")
    }
    
    func testVerifyCode() {
        /*
            This tests the verify code button action and whether login view controller
         */
        let url = URL(string: Constants.BASE_URL+"/api/v2.2/verify/")!
        var stub = StubRequest(method: .POST, url: url)
        var response = StubResponse()
        let body = "success".data(using: .utf8)!
        response.body = body
        stub.response = response
        Hippolyte.shared.add(stubbedRequest: stub)
        Hippolyte.shared.start()

        let textField: UITextField = UITextField()
        textField.text = "12345"
        verifyPhoneViewController?.verifyCodeButton = UIButton()
        verifyPhoneViewController?.otpField = textField
        verifyPhoneViewController?.verifyCode(verifyPhoneViewController!.verifyCodeButton)
        XCTAssertNotEqual(UIApplication.topViewController(), VerifyPhoneViewController())
    }
    
    func testInvalidOtpFieldValue() {
        /*
            This tests whether otp field accepts invalid value.
         */
        let textField: UITextField = UITextField()
        textField.text = "Hello"
        verifyPhoneViewController?.otpField = textField
        XCTAssertFalse((verifyPhoneViewController?.validate())!)
    }
    
    func testValidOtpFieldValue() {
        /*
            This tests otp field for valid value.
         */
        let textField: UITextField = UITextField()
        textField.text = "12345"
        verifyPhoneViewController?.otpField = textField
        XCTAssertTrue((verifyPhoneViewController?.validate())!)
    }

    
}
