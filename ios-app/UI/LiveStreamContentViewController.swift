//
//  LiveStreamContentViewController.swift
//  ios-app
//
//  Created by Testpress on 22/05/24.
//  Copyright © 2024 Testpress. All rights reserved.
//

import Foundation
import UIKit
import CourseKit

class LiveStreamContentViewController: UIViewController {
    var content: Content!
    var playerViewController: VideoPlayerViewController!
    var reloadTimer: Timer?
    
    var viewModel: ChapterContentDetailViewModel?
    
    @IBOutlet weak var playerContainer: UIView!
    @IBOutlet weak var liveChatContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayerView()
        setupLiveChatView()
        showNoticeView()
        pollUntilLiveStreamStart()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if(content.liveStream!.isRunning) {
            viewModel?.createContentAttempt()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopReloadingContent()
    }
    
    func setupPlayerView(){
        playerViewController = VideoPlayerViewController(hlsURL: content.liveStream!.streamURL, drmLicenseURL: nil)
        
        addChild(playerViewController!)
        playerContainer.addSubview(playerViewController!.view)
        playerViewController!.view.frame = playerContainer.bounds
        playerViewController.playerView.isLive = true
    }
    
    func setupLiveChatView(){
        guard content.liveStream!.isRunning else { return }
        guard let request = createLiveChatEmbedURLRequest() else {
                print("Failed to create request")
                return
            }
        
        let webViewController = createWebViewController(with: request)
        attachLiveChat(webViewController: webViewController)
    }
    
    func showNoticeView(){
        if(content.liveStream!.isEnded){
            let description = content.liveStream!.showRecordedVideo ? Strings.LIVE_ENDED_WITH_RECORDING_DESC : Strings.LIVE_ENDED_WITHOUT_RECORDING_DESC
            
            self.playerViewController.showWarning(text: description)
        } else if(content.liveStream!.isNotStarted) {
            self.playerViewController.showWarning(text: Strings.LIVE_NOT_STARTED_DESC)
        }
    }
    
    func pollUntilLiveStreamStart() {
        guard content.liveStream!.isNotStarted else { return }
        
        reloadContent()
        reloadTimer = Timer.scheduledTimer(timeInterval: 15.0, target: self, selector: #selector(reloadContent), userInfo: nil, repeats: true)
    }
    
    func stopReloadingContent() {
        reloadTimer?.invalidate()
        reloadTimer = nil
    }
    
    @objc func reloadContent() {
        fetchContent { [weak self] content, error in
            guard let self = self else { return }
            
            if let content = content {
                self.content = content
                DBManager<Content>().addData(object: content)
                if content.liveStream!.isRunning{
                    self.stopReloadingContent()
                    self.playerViewController.hideWarning()
                    self.playerViewController.playerView.play()
                    setupLiveChatView()
                    viewModel?.createContentAttempt()
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
    
    private func createLiveChatEmbedURLRequest() -> URLRequest? {
        guard let chatEmbedURLString = content.liveStream?.chatEmbedURL,
              let chatEmbedURL = URL(string: chatEmbedURLString) else {
            print("Invalid chat embed URL")
            return nil
        }
        
        var request = URLRequest(url: chatEmbedURL)
        request.setValue("JWT \( KeychainTokenItem.getToken())", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func createWebViewController(with request: URLRequest) -> WebViewController {
        let webViewController = WebViewController()
        webViewController.request = request
        webViewController.displayNavbar = false
        return webViewController
    }

    private func attachLiveChat(webViewController: WebViewController) {
        addChild(webViewController)
        liveChatContainer.addSubview(webViewController.view)
        webViewController.view.frame = liveChatContainer.bounds
        webViewController.didMove(toParent: self)
    }
}
