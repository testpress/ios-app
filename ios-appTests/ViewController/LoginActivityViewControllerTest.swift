//
//  LoginActivityViewControllerTest.swift
//  ios-appTests
//
//  Created by Karthik on 17/04/19.
//  Copyright © 2019 Testpress. All rights reserved.
//

import XCTest
import Hippolyte
@testable import ios_app

class LoginActivityViewControllerTest:XCTestCase {
    var loginActivity = [LoginActivity]()
    var controller: LoginActivityViewController!

    override func setUp() {
        super.setUp()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: Constants.LOGIN_ACTIVITY_VIEW_CONTROLLER) as? LoginActivityViewController else {
                return XCTFail("Could not instantiate ViewController from main storyboard")
        }
        
        controller = vc
        controller.loadViewIfNeeded()
        
        for i in 0..<10 {
            let data = LoginActivity(JSONString: "{\"id\": \(i),\"user_agent\": \"iPhone / iOS 12.1.4 / CFNetwork\",\"ip_address\": \"49.204.210.252\", \"last_used\": \"2019-04-17T05:42:50.463754Z\",\"location\": \"IN\",\"current_device\": \(Bool.random())}")
            loginActivity.append(data!)
        }
        controller.items = loginActivity
        controller.tableView.reloadData()
    }

    override func tearDown() {
        super.tearDown()
        Hippolyte.shared.stop()
    }
    
    func testControllerHasTableView() {
        /*
         LoginActivityViewController should be able to initiated by storyboard and it should have tableView
         */
        
        XCTAssertNotNil(controller.tableView, "Controller should have a tableview")
    }
    
    func testControllerHasLoginActivityPager() {
        /*
         LoginActivityViewController should use LoginActivityPager
         */
        XCTAssertTrue(controller.pager is LoginActivityPager)
    }
    
    func testControllerUsesLoginActivityModel() {
        /*
         LoginActivityViewController should use LoginActivity model
         */
        
        XCTAssertTrue(controller.items is [LoginActivity])
    }
    
    func testNumberOfRows() {
        let tableView = UITableView()
        let numberOfRows = controller.tableView(tableView, numberOfRowsInSection: 0)

        XCTAssertEqual(numberOfRows, loginActivity.count)
    }
    
    func testCellForRow() {
        let tableView = UITableView()
        let cell = controller.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as! LoginActivityCell
        var lastUsedTime = String()
        if loginActivity[0].currentDevice {
            lastUsedTime = "Currently using"
        } else {
            lastUsedTime = "Last Used : \(FormatDate.getElapsedTime(dateString: loginActivity[0].lastUsed))"
        }
        
        
        XCTAssertEqual(cell.ipAddress.text, loginActivity[0].ipAddress)
        XCTAssertEqual(cell.lastUsedTime.text, lastUsedTime)
        XCTAssertEqual(cell.deviceName.text, loginActivity[0].userAgent)
    }
    
    func testTableViewHasCells() {
        let cell = controller.tableView.dequeueReusableCell(withIdentifier: "LoginActivityTableCell")
        
        XCTAssertNotNil(cell, "TableView should be able to dequeue cell with identifier: 'Cell'")
    }
    
    func testHasZeroSectionsWhenZeroItems() {
        controller.items = [LoginActivity]()
        controller.tableView.reloadData()

        XCTAssertEqual(controller.tableView.numberOfSections, 0)
    }
    
    func testHasOneSectionWhenItemsArePresent() {
        XCTAssertEqual(controller.tableView.numberOfSections, 1)
    }

    /*
    func testLoadItems(){
        controller.items = [LoginActivity]()
        controller.tableView.reloadData()
        let url = URL(string: TPEndpointProvider(.loginActivity, queryParams:["filter": "app", "page": "1"]).getUrl())!
        var stub = StubRequest(method: .GET, url: url)
        var response = StubResponse()
        response.body = "{\"count\": 1, \"next\": null, \"previous\": null, \"per_page\": 20, \"results\": [ {\"id\": 21,\"user_agent\": \"iPhone / iOS 12.1.4 / CFNetwork\",\"ip_address\": \"49.204.210.252\",\"last_used\": \"2019-04-17T05:42:50.463754Z\",\"location\": \"IN\", \"current_device\": false}]}".data(using: .utf8)!
        stub.response = response
        Hippolyte.shared.add(stubbedRequest: stub)
        Hippolyte.shared.start()
        controller.pager.reset()
        let expectation = self.expectation(description: "Stubs network call")
        controller.loadItems()
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
            _ in
            if !self.controller.loadingItems {
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(controller.items.count, 1)
    }
    */
}
