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


public class VideoContentViewModel {
    public var content: Content!
    public var contentAttemptId: Int?
    public var startTime: String?
    public var videoPlayerView: VideoPlayerView?
    public weak var timer: Timer?
    
    
    public init(_ content: Content){
        self.content = content
    }
    
    public func getTitle() -> String{
        return content!.name
    }
    
    public func getDescription()  -> String{
        var description = ""
 
        if !(content?.contentDescription?.isEmpty ?? true) {
            description = content.contentDescription!
        }
        return description
    }
    
    public func createContentAttempt() {
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
                
                if (seconds.doubleValue > Double(1.0)) {
                    self.videoPlayerView?.goTo(seconds: Float(seconds.doubleValue))
                }
        })
    }
    
    @objc public func updateVideoAttempt() {
        if ((videoPlayerView?.player?.isPlaying ?? true) && ((contentAttemptId != nil))) {

            if ((videoPlayerView?.player?.currentTimeInSeconds)! <= Double(1.0)) {
                return
            }

            let currentTime = String(format: "%.4f", (videoPlayerView?.player?.currentTimeInSeconds)!)
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
                    return
                }
            })
        }
    }
    
    
    public func removeBookmark(completion: (() -> Void)?) {
        let urlPath = TPEndpointProvider.getBookmarkPath(bookmarkId: content!.bookmarkId.value!)
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
        })
    }
    
}
