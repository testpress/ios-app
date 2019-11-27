//
//  VideoContentViewController.swift
//  ios-app
//
//
//  Copyright © 2019 Testpress. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//


import UIKit
import AVKit
import AVFoundation
import Alamofire
import Sentry


class VideoContentViewController: UIViewController {
    var content: Content!
    var playerViewController:AVPlayerViewController!
    var viewModel: VideoContentViewModel!
    var contentAttemptCreationDelegate: ContentAttemptCreationDelegate?
    var contentAttemptId: Int?
    var startTime: String?
    weak var timer: Timer?
    var myView: UIView?

    @IBOutlet weak var videoPlayer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = VideoContentViewModel(content)
        initAndSubviewPlayerViewController()
        titleLabel.text = viewModel.getTitle()
        desc.text = viewModel.getDescription()
        createContentAttempt()
        if #available(iOS 11.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(screenCaptureChanged), name: NSNotification.Name.UIScreenCapturedDidChange, object: nil)
        }
         playerViewController.player?.addObserver(self, forKeyPath: "rate", options: [.new, .initial], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath  == "rate" {
            self.startTime = String(format: "%.4f", playerViewController.player!.currentTimeInSeconds)
        }
        
    }
    
    @objc func screenCaptureChanged() {
        if #available(iOS 11.0, *) {
            if (UIScreen.main.isCaptured) {
                print("Screen is being recorded")
            } else {
                print("Screen recording is done")
            }
        }
    }
    
    func initAndSubviewPlayerViewController() {
        playerViewController = viewModel.initializePlayer()
        addChildViewController(playerViewController)
        view.addSubview(playerViewController.view)
        playerViewController.didMove(toParentViewController: self)
        viewModel.handleOrientation()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.updateVideoAttempt), userInfo: nil, repeats: true)

    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let playerFrame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.width, height: videoPlayer.frame.height)
        playerViewController.view.frame = playerFrame
        scrollView.contentSize.height = stackView.frame.size.height
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
                print("Seconds \(seconds)")
                self.playerViewController.player?.seek(to: seconds)
                
                if self.content.attemptsCount == 0 {
                    self.contentAttemptCreationDelegate?.newAttemptCreated()
                }
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        viewModel.handleOrientation()
    }
    
}
