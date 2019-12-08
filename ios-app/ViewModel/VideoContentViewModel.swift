//
//  VideoContentViewModel.swift
//  ios-app
//
//  Created by Karthik raja on 12/8/19.
//  Copyright © 2019 Testpress. All rights reserved.
//

import Foundation
import AVKit
import Alamofire
import Sentry
import TTGSnackbar


class VideoContentViewModel {
    let content: Content!
    var contentAttemptId: Int?
    var startTime: String?
    var videoPlayerView: VideoPlayerView?
    weak var timer: Timer?
    
    
    public init(_ content: Content){
        self.content = content
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
                let seconds = NSString(string: (contentAttempt?.video.lastPosition)!)
                self.videoPlayerView?.startTime = Float(seconds.doubleValue)
                self.videoPlayerView?.goTo(seconds: Float(seconds.doubleValue))
        })
    }
    
    @objc func updateVideoAttempt() {
        if (videoPlayerView?.player.isPlaying ?? true) {
            let currentTime = String(format: "%.4f", (videoPlayerView?.player.currentTimeInSeconds)!)
            let parameters: Parameters = [
                "last_position": currentTime,
                "time_ranges": [[videoPlayerView!.startTime, currentTime]]
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
    
    
    func removeBookmark(completion: (() -> Void)?) {
        let urlPath = TPEndpointProvider.getBookmarkPath(bookmarkId: content.bookmarkId)
        TPApiClient.apiCall(
            endpointProvider: TPEndpointProvider(.delete, urlPath: urlPath),
            completion: {
                void, error in
                if let error = error {
                    debugPrint(error.message ?? "No error")
                    debugPrint(error.kind)
                    let (_, _, description) = error.getDisplayInfo()
                    TTGSnackbar(message: description, duration: .middle).show()
                    return
                }
                TTGSnackbar(
                    message: Strings.BOOKMARK_DELETED_SUCCESSFULLY,
                    duration: .middle
                    ).show()
                
                completion?()
//                self.udpateBookmarkButtonState(bookmarkId: nil)
        })
    }
    
}
