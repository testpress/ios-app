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
        let url = URL(string: "https://lmsdemo.testpress.in/api/v2.2/verify/")!
        var stub = StubRequest(method: .POST, url: url)
        var response = StubResponse()
        let body = "success".data(using: .utf8)!
        response.body = body
        stub.response = response
        Hippolyte.shared.add(stubbedRequest: stub)
        Hippolyte.shared.start()
        let label = UIButton()
        label.setTitle("button", for:UIControl.State.normal)
        verifyPhoneViewController!.verifyCodeButton = label

        let textField: UITextField = UITextField()
        textField.text = "12345"
        verifyPhoneViewController?.otpField = textField
        verifyPhoneViewController?.verifyCode(verifyPhoneViewController!.verifyCodeButton)
        XCTAssertNotEqual(UIApplication.topViewController(), VerifyPhoneViewController())
    }
    
    
    func testAuthenticateFailure() {
        /*
         This tests for authentication failure
         */
        let url = URL(string: "https://lmsdemo.testpress.in/api/v2.2/auth-token/")!
        var stub = StubRequest(method: .POST, url: url)
        var response = StubResponse()
        response = StubResponse(statusCode: 400)
        let jsonObject: [String: Any] = [
            "non_field_errors": "Unable to login with provided credentials",
            ]
  
        do {
            try response.body = JSONSerialization.data(withJSONObject: jsonObject,options: .prettyPrinted)
        } catch {
            response.body = "hello".data(using: .utf8)
        }
        
        stub.response = response
        Hippolyte.shared.add(stubbedRequest: stub)
        Hippolyte.shared.start()
        
        verifyPhoneViewController?.authenticate(username: "demo", password: "password", provider: .TESTPRESS)

        XCTAssertTrue(UIApplication.topViewController() is LoginViewController)
    }
    
//    func testAuthenticateSuccess() {
//        /*
//         This tests authentication success
//         */
//        let url = URL(string: Constants.BASE_URL+"/api/v2.2/auth-token/")!
//        var stub = StubRequest(method: .POST, url: url)
//        var response = StubResponse()
//        response = StubResponse(statusCode: 200)
//        
//        let jsonObject: [String: Any] = [
//            "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6MjY5LCJ1c2VyX2lkIjoyNjksImVtYWlsIjoia2FydGhpa0B0ZXN0cHJlc3MuaW4iLCJleHAiOjE1NDYwMDcyOTJ9.ux0YtD-pGOBXPN6K6hhlCstRCmAhCDJF4R2YBO8t5bM",
//        ]
//        
//        do {
//            try response.body = JSONSerialization.data(withJSONObject: jsonObject,options: .prettyPrinted)
//        } catch {
//            response.body = "hello".data(using: .utf8)
//        }
//
//        stub.response = response
//        Hippolyte.shared.add(stubbedRequest: stub)
//        Hippolyte.shared.start()
//        
//        verifyPhoneViewController?.authenticate(username: "demo", password: "password", provider: .TESTPRESS)
//    
//        XCTAssertTrue(UIApplication.topViewController() is ActivityFeedTableViewController)
//    }
    
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
