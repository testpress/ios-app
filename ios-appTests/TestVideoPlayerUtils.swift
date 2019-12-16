//
//  TestVideoPlayerUtils.swift
//  ios-appTests
//
//  Created by Karthik raja on 12/9/19.
//  Copyright © 2019 Testpress. All rights reserved.
//

import XCTest
@testable import ios_app

class TestVideoPlayerUtils: XCTestCase {
    
    func testPlaybackSpeedEnum() {
        XCTAssertEqual(PlaybackSpeed.verySlow.label, "0.5x")
        XCTAssertEqual(PlaybackSpeed.slow.label, "0.75x")
        XCTAssertEqual(PlaybackSpeed.normal.label, "1x")
        XCTAssertEqual(PlaybackSpeed.fast.label, "1.25x")
        XCTAssertEqual(PlaybackSpeed.veryFast.label, "1.5x")
        XCTAssertEqual(PlaybackSpeed.double.label, "2x")

        XCTAssertEqual(PlaybackSpeed.verySlow.value, 0.5)
        XCTAssertEqual(PlaybackSpeed.slow.value, 0.75)
        XCTAssertEqual(PlaybackSpeed.normal.value, 1.00)
        XCTAssertEqual(PlaybackSpeed.fast.value, 1.25)
        XCTAssertEqual(PlaybackSpeed.veryFast.value, 1.5)
        XCTAssertEqual(PlaybackSpeed.double.value, 2)
    }
    
    func testVideoDurationType() {
        XCTAssertEqual(VideoDurationType.remainingTime.getDurationString(seconds: 0.00), "00:00")
        XCTAssertEqual(VideoDurationType.remainingTime.getDurationString(seconds: 60.00), "01:00")
        XCTAssertEqual(VideoDurationType.remainingTime.getDurationString(seconds: 3600.00), "01:00:00")
        
        XCTAssertEqual(VideoDurationType.totalTime.value(seconds: 3600.00, total: 6000.00), "01:40:00")
        XCTAssertEqual(VideoDurationType.remainingTime.value(seconds: 3600.00, total: 6000.00), "-40:00")
    }
}
