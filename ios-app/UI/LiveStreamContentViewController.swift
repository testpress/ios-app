//
//  LiveStreamContentViewController.swift
//  ios-app
//
//  Created by Testpress on 22/05/24.
//  Copyright © 2024 Testpress. All rights reserved.
//

import Foundation
import UIKit

class LiveStreamContentViewController: UIViewController {
    var content: Content!
    var playerViewController: VideoPlayerViewController!
    var reloadTimer: Timer?
    
    @IBOutlet weak var playerContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayerView()
        showNoticeView()
        startReloadingContent()
    }
    
    func setupPlayerView(){
        playerViewController = VideoPlayerViewController(hlsURL: content.liveStream!.streamURL, drmLicenseURL: nil)
        
        addChild(playerViewController!)
        playerContainer.addSubview(playerViewController!.view)
        playerViewController!.view.frame = playerContainer.bounds
    }
    
    func showNoticeView(){
        if(content.liveStream!.isEnded){
            let description = content.liveStream!.showRecordedVideo ? Strings.LIVE_ENDED_WITH_RECORDING_DESC : Strings.LIVE_ENDED_WITHOUT_RECORDING_DESC
            
            self.playerViewController.showWarning(text: description)
        } else if(content.liveStream!.isNotStarted) {
            self.playerViewController.showWarning(text: Strings.LIVE_NOT_STARTED_DESC)
        }
    }
    
    func startReloadingContent() {
        print("startReloadingContent 47")
        guard content.liveStream!.isNotStarted else { return }
        print("startReloadingContent 46")
        
        reloadContent()
        reloadTimer = Timer.scheduledTimer(timeInterval: 15.0, target: self, selector: #selector(reloadContent), userInfo: nil, repeats: true)
    }
    
    func stopReloadingContent() {
        print("stop called")
        reloadTimer?.invalidate()
        reloadTimer = nil
    }
    
    @objc func reloadContent() {
        print("reloadContent called")
        fetchContent { [weak self] content, error in
            guard let self = self else { return }
            
            if let content = content {
                self.content = content
                DBManager<Content>().addData(object: content)
                if content.liveStream!.isRunning{
                    self.stopReloadingContent()
                    self.playerViewController.hideWarning()
                    self.playerViewController.playerView.play()
                }
            }
        }
    }
    
    private func fetchContent(completion: @escaping (Content?, TPError?) -> Void) {
        TPApiClient.request(
            type: Content.self,
            endpointProvider: TPEndpointProvider(.get, url: content.url),
            completion: completion
        )
    }
}
