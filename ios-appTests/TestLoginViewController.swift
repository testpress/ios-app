//
//  TestLoginViewController.swift
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


class TestLoginViewController: XCTestCase {

    var controller: LoginViewController!

    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        
        saveInstituteSettings(getInstituteSettings())
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: Constants.LOGIN_VIEW_CONTROLLER) as? LoginViewController else {
                return XCTFail("Could not instantiate ViewController from main storyboard")
        }
        
        controller = vc
        controller.loadViewIfNeeded()
    }
    
    func saveInstituteSettings(_ instituteSettings: InstituteSettings) {
        DBManager<InstituteSettings>().deleteAllFromDatabase()
        DBManager<InstituteSettings>().addData(objects: [instituteSettings])
    }
    
    
    func getInstituteSettings(allowSignup: Bool? = false, facebookLoginEnabled: Bool? = false) -> InstituteSettings {
        let instituteSettings = InstituteSettings()
        instituteSettings.baseUrl = Constants.BASE_URL
        instituteSettings.allowSignup = allowSignup!
        instituteSettings.facebookLoginEnabled = facebookLoginEnabled!
        return instituteSettings
    }

    func testVisibiltyOfSignupLayout() {
        /*
         Signup layout's visibility should depend on institute settings
         */
        XCTAssertTrue(controller.signUpLayout.isHidden)
        
        saveInstituteSettings(getInstituteSettings(allowSignup: true))
        controller.loadView()
        
        XCTAssertFalse(controller.signUpLayout.isHidden)
    }
    
    func testVisibiltyOfFacebookLogin() {
        /*
         Facebook login's visibility should depend on institute settings
         */
        XCTAssertTrue(controller.socialLoginLayout.isHidden)
        
        saveInstituteSettings(getInstituteSettings(facebookLoginEnabled: true))
        controller.loadView()
        
        XCTAssertFalse(controller.socialLoginLayout.isHidden)
    }

}
