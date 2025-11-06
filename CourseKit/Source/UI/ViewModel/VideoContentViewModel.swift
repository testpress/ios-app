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
import TTGSnackbar


public class VideoContentViewModel {
    public var content: Content!
    public var contentAttemptId: Int?
    public var startTimeString: String?
    public weak var timer: Timer?
    public weak var delegate: VideoContentViewModelDelegate?
    
    
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
                self.startTimeString = contentAttempt?.video.lastPosition
                self.contentAttemptId = contentAttempt!.objectID
                let seconds = NSString(string: (contentAttempt?.video.lastPosition)!)
                
                if (seconds.doubleValue > Double(1.0)) {
                    self.delegate?.didUpdatePlayerTime(to: Float(seconds.doubleValue))
                }
        })
    }
    
    public func updateVideoAttempt(currentTime: Float64?) {
        if currentTime != nil && contentAttemptId != nil {

            if (currentTime! <= Double(1.0)) {
                return
            }

            let currentTime = String(format: "%.4f", currentTime!)
            let parameters: Parameters = [
                "last_position": currentTime,
                "time_ranges": [[startTimeString, currentTime]]
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

public protocol VideoContentViewModelDelegate: AnyObject {
    func didUpdatePlayerTime(to time: Float)
}
