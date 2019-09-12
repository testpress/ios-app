//
//  LoginActivity.swift
//  ios-appTests
//
//  Created by Karthik on 17/04/19.
//  Copyright © 2019 Testpress. All rights reserved.
//

import XCTest
import Hippolyte
@testable import ios_app

class LoginActivityTest:XCTestCase {
    var model: LoginActivity!
    let dictionary : [String : Any] = ["id": 1, "user_agent": "iPhone / iOS 12.1.4 / CFNetwork", "ip_address": "127.0.0.1","last_used": "2019-04-17T05:42:50.463754Z", "location": "IN", "current_device": false]

    override func setUp() {
        super.setUp()
        model = LoginActivity()
    }
    
    override func tearDown() {
        super.tearDown()
        Hippolyte.shared.stop()
    }
    
    func testModelAttributes() {
        XCTAssertTrue(model.id is Int)
        XCTAssertTrue(model.location is String)
        XCTAssertTrue(model.userAgent is String)
        XCTAssertTrue(model.lastUsed is String)
        XCTAssertTrue(model.ipAddress is String)
        XCTAssertTrue(model.currentDevice is Bool)
    }
    
    func testValueMapping() {
        /*
         Json data should be mapped to model's attributes appropriately.
         */
        self.startListeningForURL()
        TPApiClient.apiCall(endpointProvider: TPEndpointProvider(.loginActivity), completion: {
            item, error in
            if let json = item {
                self.model = TPModelMapper<LoginActivity>().mapFromJSON(json: json)
            }
        })
        
        let expectation = self.expectation(description: "Stubs network call")
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
            _ in
            if self.model != nil{
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(self.model.id, dictionary["id"] as! Int)
        XCTAssertEqual(self.model.userAgent, dictionary["user_agent"] as! String)
        XCTAssertEqual(self.model.lastUsed, dictionary["last_used"] as! String)
        XCTAssertEqual(self.model.location, dictionary["location"] as! String)
        XCTAssertEqual(self.model.currentDevice, dictionary["current_device"] as! Bool)
        
    }
    
    func startListeningForURL() {
        let url = URL(string: TPEndpointProvider(.loginActivity).getUrl())!
        var stub = StubRequest(method: .GET, url: url)
        var response = StubResponse()
        response.body = jsonData().data(using: .utf8)!
        stub.response = response
        Hippolyte.shared.add(stubbedRequest: stub)
        Hippolyte.shared.start()
    }
    
    func jsonData() -> String {
        if let theJSONData = try?  JSONSerialization.data(
            withJSONObject: dictionary,
            options: .prettyPrinted
            ),
            let json_string = String(data: theJSONData, encoding: String.Encoding.ascii) {
            return json_string
        }
        return "null"
    }
    
}
