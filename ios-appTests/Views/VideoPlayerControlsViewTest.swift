//
//  VideoPlayerControlsViewTest.swift
//  ios-appTests
//
//  Created by Karthik raja on 12/9/19.
//  Copyright © 2019 Testpress. All rights reserved.
//

import XCTest
@testable import ios_app

class TestVideoPlayerControlsView: XCTestCase {
    var playerControlsView: VideoPlayerControlsView! = .fromNib("VideoPlayerControls")
    
    func testControlsSetup() {
        playerControlsView.setUp()
        
        XCTAssertTrue(playerControlsView.isHidden)
        XCTAssertEqual(playerControlsView.backgroundColor, UIColor.black.withAlphaComponent(0.4))
        XCTAssertEqual(playerControlsView.playerStatus, .playing)
    }
    
    func testStartLoading() {
        playerControlsView.startLoading()
        
        XCTAssertFalse(playerControlsView.isHidden)
        XCTAssertTrue(playerControlsView.rewindButton.isHidden)
        XCTAssertTrue(playerControlsView.playPauseButton.isHidden)
        XCTAssertTrue(playerControlsView.forwardButton.isHidden)
        XCTAssertFalse(playerControlsView.loadingIndicator.isHidden)
        XCTAssertTrue(playerControlsView.loadingIndicator.isAnimating)
    }
    
    func testStopLoading() {
        playerControlsView.loadingIndicator.startAnimating()
        playerControlsView.stopLoading()
        
        XCTAssertTrue(playerControlsView.isHidden)
        XCTAssertFalse(playerControlsView.rewindButton.isHidden)
        XCTAssertFalse(playerControlsView.playPauseButton.isHidden)
        XCTAssertFalse(playerControlsView.forwardButton.isHidden)
        XCTAssertTrue(playerControlsView.loadingIndicator.isHidden)
        XCTAssertFalse(playerControlsView.loadingIndicator.isAnimating)
    }
    
    func testUpdateDuration() {
        playerControlsView.updateDuration(seconds: 60.00, videoDuration: 3600.00)
        
        XCTAssertEqual(playerControlsView.currentDurationLabel.text, "01:00")
        XCTAssertEqual(playerControlsView.totalDurationLabel.text, "-59:00")
        XCTAssertEqual(playerControlsView.currentDuration, 60.00)
        XCTAssertEqual(playerControlsView.totalDuration, 3600.00)
        
        playerControlsView.durationType = .totalTime
        playerControlsView.updateDuration(seconds: 60.00, videoDuration: 3600.00)
        XCTAssertEqual(playerControlsView.totalDurationLabel.text, "01:00:00")
    }
    
    func testChangeButtonStatus() {
        playerControlsView.playerStatus = .playing
        XCTAssertEqual(playerControlsView.playPauseButton.currentImage, Images.PauseIcon.image)
        
        playerControlsView.playerStatus = .paused
        XCTAssertEqual(playerControlsView.playPauseButton.currentImage, Images.PlayIcon.image)
        
        playerControlsView.playerStatus = .finished
        XCTAssertEqual(playerControlsView.playPauseButton.currentImage, Images.ReloadIcon.image)
    }
}
