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
    var position: Int!
    var emptyView: EmptyView!
    var playerViewController: VideoPlayerViewController!
    
    @IBOutlet weak var playerContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emptyView = EmptyView.getInstance(parentView: view)
        setupPlayerView()
        showNoticeView()
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
        } else if(content.liveStream!.isRunning) {
            self.playerViewController.showWarning(text: Strings.LIVE_NOT_STARTED_DESC)
        }
    }
    
    func reloadContent() {
        fetchContent { [weak self] content, error in
            guard let self = self else { return }
 
            if let error = error {
                self.handleError(error)
            } else if let content = content {
                self.handleSuccess(content)
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

    private func handleError(_ error: TPError) {
        var retryHandler: (() -> Void)?
        if error.kind == .network {
            retryHandler = { [weak self] in
                self?.reloadContent()
            }
        }
        let (image, title, description) = error.getDisplayInfo()
        emptyView.show(image: image, title: title, description: description, retryHandler: retryHandler)
    }

    private func handleSuccess(_ content: Content) {
        self.content = content
        DBManager<Content>().addData(object: content)
    }}
