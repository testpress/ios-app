//
//  VideoPlayerViewTest.swift
//  ios-appTests
//
//  Created by Karthik raja on 12/9/19.
//  Copyright © 2019 Testpress. All rights reserved.
//

import XCTest
import AVKit
@testable import ios_app

class TestVideoPlayerView: XCTestCase {
    var videoPlayerView: VideoPlayerView!
    
    override func setUp() {
        videoPlayerView = VideoPlayerView(frame: CGRect(x:0, y:0, width:0, height:0), url: URL(string: "http://google.com")!)
    }
    
    func testInit() {
        XCTAssertTrue(videoPlayerView.controlsContainerView.loadingIndicator.isAnimating)
    
        let url: URL? = (videoPlayerView.player?.currentItem?.asset as? AVURLAsset)?.url
        XCTAssertEqual(url, URL(string: "http://google.com")!)
    }
    
    func testGoto() {
        videoPlayerView.goTo(seconds: 21.00)
        XCTAssertEqual(CMTimeGetSeconds(videoPlayerView.player!.currentTime()), 21.00)
        
        videoPlayerView.rewind()
        XCTAssertEqual(CMTimeGetSeconds(videoPlayerView.player!.currentTime()), 11.00)
    }
    
    func testFullScreen() {
        videoPlayerView.fullScreen()
        
        XCTAssertTrue(UIDevice.current.orientation.isLandscape)
    }
    
    func testPlayVideoShouldSetCurrentPlaybackSpeedAs1() {
        videoPlayerView.playVideo(url: URL(string: "http://google.com")!)
        
        XCTAssertEqual(1.0, videoPlayerView.currentPlaybackSpeed)
    }
    
    func testChangePlaybackSpeedShouldSetCurrentPlaybackSpeed() {
        
        videoPlayerView.changePlaybackSpeed(speed: PlaybackSpeed.double)
        
        XCTAssertEqual(PlaybackSpeed.double.value, videoPlayerView.currentPlaybackSpeed)
    }
    
    func testPlayShouldUseCurrentPlaybackSpeed() {
        videoPlayerView.currentPlaybackSpeed = 5.0
        videoPlayerView.play()
        
        XCTAssertEqual(5.0, videoPlayerView.getCurrenPlaybackSpeed())
    }
}
