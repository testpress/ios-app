//
//  LiveStreamContentViewController.swift
//  ios-app
//
//  Created by Testpress on 22/05/24.
//  Copyright © 2024 Testpress. All rights reserved.
//

import Foundation
import UIKit
import TPStreamsSDK

class LiveStreamContentViewController: BaseUIViewController {
    var content: Content!
    var player: TPAVPlayer?
    var playerViewController: TPStreamPlayerViewController!
    var reloadTimer: Timer?
    
    var viewModel: ChapterContentDetailViewModel?
    
    @IBOutlet weak var playerContainer: UIView!
    @IBOutlet weak var liveChatContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayerView()
        setupLiveChatView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if(content.liveStream!.isRunning) {
            viewModel?.createContentAttempt()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
    }
    
    func setupPlayerView(){
        player?.pause()
        player = nil
        player = TPAVPlayer(assetID: content.uuid!, accessToken: ""){ error in
            guard error == nil else {
                print("Setup error: \(error!.localizedDescription)")
                return
            }
        }
        playerViewController = TPStreamPlayerViewController()
        playerViewController?.player = player
        
        
        let config = TPStreamPlayerConfigurationBuilder()
            .setPreferredForwardDuration(15)
            .setPreferredRewindDuration(5)
            .setprogressBarThumbColor(TestpressCourse.shared.primaryColor)
            .setwatchedProgressTrackColor(TestpressCourse.shared.primaryColor)
            .build()
        
        playerViewController?.config = config
        
        addChild(playerViewController!)
        playerContainer.addSubview(playerViewController!.view)
        playerViewController!.view.frame = playerContainer.bounds
        player?.play()
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
    
    @objc func reloadContent() {
        fetchContent { [weak self] content, error in
            guard let self = self else { return }
            
            if let content = content {
                self.content = content
                DBManager<Content>().addData(object: content)
                if content.liveStream!.isRunning{
                    setupPlayerView()
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
