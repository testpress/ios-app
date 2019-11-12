//
//  Testpress_iOS_AppUITests.swift
//  Testpress iOS AppUITests
//
//  Created by Karthik on 02/01/19.
//  Copyright © 2019 Testpress. All rights reserved.
//

import XCTest

class Testpress_iOS_AppUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

//    func testCountryCode() {
//        
//        let app = XCUIApplication()
//        let scrollViewsQuery = app.scrollViews
//        scrollViewsQuery.otherElements.buttons["Sign up"].tap()
//
//        let textField = scrollViewsQuery.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .other).element(boundBy: 0).children(matching: .textField).element(boundBy: 0)
//
//        XCTAssertEqual(textField.value as! String, "91")
//    
//        textField.tap()
//        app/*@START_MENU_TOKEN@*/.pickerWheels["Andorra"]/*[[".pickers.pickerWheels[\"Andorra\"]",".pickerWheels[\"Andorra\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeUp()
//
//        let toolbarDoneButtonButton = app.toolbars["Toolbar"].buttons["Toolbar Done Button"]
//        toolbarDoneButtonButton.tap()
//    
//        XCTAssertEqual(textField.value as! String, "226")
//    }

}
