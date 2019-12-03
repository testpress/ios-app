//
//  VideoContentViewModel.swift
//  ios-app
//
//  Created by Karthik raja on 11/27/19.
//  Copyright © 2019 Testpress. All rights reserved.
//

import Foundation
import AVKit
import Alamofire
import Sentry


class VideoContentViewModel {
    let content: Content!
    let playerViewController = AVPlayerViewController()
    var contentAttemptId: Int?
    var startTime: String?
    weak var timer: Timer?
    var myView: UIView?
    
    
    public init(_ content: Content){
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
    
    func startPeriodicAttemptUpdater() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.updateVideoAttempt), userInfo: nil, repeats: true)
    }
    
    func stopPeriodicAttemptUpdater() {
        timer?.invalidate()
    }
    
    func createContentAttempt() {
        let url = TPEndpointProvider.getContentAttemptUrl(contentID: content.id)
        TPApiClient.request(
            type: ContentAttempt.self,
            endpointProvider: TPEndpointProvider(.post, url: url),
            completion: {
                contentAttempt, error in
                if let error = error {
                    debugPrint(error.message ?? "No error")
                    debugPrint(error.kind)
                    return
                }
                self.startTime = contentAttempt?.video.lastPosition
                self.contentAttemptId = contentAttempt!.objectID
                let seconds = CMTimeMakeWithSeconds((contentAttempt?.video.lastPosition as! NSString).doubleValue, CMTimeScale(NSEC_PER_MSEC))
                self.playerViewController.player?.seek(to: seconds)
        })
    }
    
    @objc func updateVideoAttempt() {
        if (playerViewController.player!.isPlaying) {
            let currentTime = String(format: "%.4f", playerViewController.player!.currentTimeInSeconds)
            let parameters: Parameters = [
                "last_position": currentTime,
                "time_ranges": [[self.startTime, currentTime]]
            ]
            let url = TPEndpointProvider.getVideoAttemptPath(attemptID: contentAttemptId!)
            
            TPApiClient.apiCall(endpointProvider: TPEndpointProvider(.put, url: url), parameters: parameters,completion: {
                videoAttempt, error in
                if let error = error {
                    debugPrint(error.message ?? "No error")
                    debugPrint(error.kind)
                    let event = Event(level: .error)
                    event.message = error.message ?? "No error"
                    Client.shared?.send(event: event)
                    return
                }
            })
        }
    }
    
}
