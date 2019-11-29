//
//  VideoContentViewModel.swift
//  ios-app
//
//  Created by Karthik raja on 11/27/19.
//  Copyright © 2019 Testpress. All rights reserved.
//

import Foundation
import AVKit

class VideoContentViewModel {
    let content: Content!
    let playerViewController = AVPlayerViewController()

    
    public init(_ content: Content) {
        self.content = content
    }
    
    func initializePlayer() -> AVPlayerViewController {
        let videoURL = URL(string: content.video!.url!)
        let player = AVPlayer(url: videoURL!)
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])
        player.rate = 1
        playerViewController.player = player
        return playerViewController
    }
    
    func getTitle() -> String {
        return content.video!.title
    }
    
    func getDescription() -> String {
        return content.description!
    }
    
    
    func handleOrientation() {
        if UIDevice.current.orientation.isLandscape {
            playerViewController.enterFullScreen()
        } else {
            playerViewController.exitFullScreen()
        }
    }
    
}
