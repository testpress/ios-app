//
//  WebViewControllerTest.swift
//  ios-appTests
//
//  Created by Karthik on 17/03/19.
//  Copyright © 2019 Testpress. All rights reserved.
//

import Foundation
@testable import ios_app
import Hippolyte
import XCTest

class TestWebViewController: XCTestCase {
    
    let appDelegate = AppDelegate();
    var webViewController: WebViewController?
    
    
    override func setUp() {
        webViewController = WebViewController()
        webViewController?.url = Constants.BASE_URL
        webViewController?.activityIndicator = UIUtils.initActivityIndicator(parentView: (webViewController?.view)!)
    }
    
    override func tearDown() {
        webViewController = nil
        Hippolyte.shared.stop()
    }
    
    func testUseSSOLoginDefaultValue() {
        /*
         By default sso_login should not be used.
        */
        XCTAssertFalse(webViewController!.use_sso_login)
    }
    
    
    func testRemoveCookies() {
        /*
         removeCookies method should clear existing cookies.
        */
        let cookieProperties: [HTTPCookiePropertyKey : Any] = [.name : "csrftoken",
                                                               .value : "abcderf",
                                                               .domain : "www.example.com",
                                                               .originURL : "www.example.com",
                                                               .path : "/",
                                                               .version : "0",
                                                               .expires : Date().addingTimeInterval(2629743)
        ]
        if let cookie = HTTPCookie(properties: cookieProperties) {
            HTTPCookieStorage.shared.setCookie(cookie)
        }
        XCTAssertEqual(HTTPCookieStorage.shared.cookies!.count, 1)

        webViewController?.removeCookies()
        XCTAssertEqual(HTTPCookieStorage.shared.cookies!.count, 0)
    }
    
    
}

