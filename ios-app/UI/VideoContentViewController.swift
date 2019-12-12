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
    var videoPlayerView: VideoPlayerView!
    var viewModel: VideoContentViewModel!
    var customView: UIView!
    var warningLabel: UILabel!
    
    @IBOutlet weak var videoPlayer: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = VideoContentViewModel(content)
        initVideoPlayerView()
        view.addSubview(videoPlayerView)
        viewModel.videoPlayerView = videoPlayerView
        showOrHideBottomBar()
        viewModel.createContentAttempt()
        addCustomView()
        handleExternalDisplay()
        
        if #available(iOS 11.0, *) {
            handleScreenCapture()
        }
    }
    
    func addCustomView() {
        warningLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        warningLabel.textColor = UIColor.white
        warningLabel.textAlignment = .center
        warningLabel.numberOfLines = 3
        
        customView = UIView(frame: videoPlayerView.frame)
        customView.backgroundColor = UIColor.black
        customView.center = CGPoint(x: view.center.x, y: videoPlayerView.center.y)
        warningLabel.center = customView.center
        customView.addSubview(warningLabel)
        customView.isHidden = true
        view.addSubview(customView)
    }
    
    func showWarning(text: String) {
        videoPlayerView.pause()
        videoPlayerView.isHidden = true
        warningLabel.text = text
        warningLabel.sizeToFit()
        customView.isHidden = false
    }
    
    func hideWarning() {
        videoPlayerView.isHidden = false
        customView.isHidden = true
    }
    
    @objc func handleExternalDisplay() {
        if (UIScreen.screens.count > 1) {
            showWarning(text: "Please stop casting to external devices")
        } else {
            hideWarning()
        }
    }
    
    @available(iOS 11.0, *)
    @objc func handleScreenCapture() {
        if (UIScreen.main.isCaptured) {
           showWarning(text: "Please stop screen recording to continue watching video")
        } else {
            hideWarning()
        }
    }
    
    func initVideoPlayerView() {
        let playerFrame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.width, height: videoPlayer.frame.height)
        videoPlayerView = VideoPlayerView(frame: playerFrame, url: URL(string: content.video!.url!)!)
        videoPlayerView.playerDelegate = self
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        showOrHideBottomBar()
    }
    
    func showOrHideBottomBar() {
        if let contentDetailPageViewController = self.parent?.parent as? ContentDetailPageViewController {
            contentDetailPageViewController.disableSwipeGesture()

            if (UIDevice.current.orientation.isLandscape) {
                contentDetailPageViewController.hideBottomNavBar()
            } else {
                contentDetailPageViewController.showBottomNavbar()
            }
        }
    }
    
    func handleFullScreen() {
        var playerFrame = CGRect(x: 0, y: 0, width: view.frame.width, height: videoPlayer.frame.height)
        UIApplication.shared.keyWindow?.removeVideoPlayerView()
        view.addSubview(videoPlayerView)
        
        if (UIDevice.current.orientation.isLandscape) {
            playerFrame = UIScreen.main.bounds
            UIApplication.shared.keyWindow!.addSubview(videoPlayerView)
        }
        videoPlayerView.frame = playerFrame
        customView.frame = videoPlayerView.frame
        videoPlayerView.layoutIfNeeded()
        videoPlayerView.playerLayer?.frame = playerFrame
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        handleFullScreen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.startPeriodicAttemptUpdater()
        videoPlayerView.addObservers()

        if let contentDetailPageViewController = self.parent?.parent as? ContentDetailPageViewController {
            contentDetailPageViewController.disableSwipeGesture()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleExternalDisplay), name: .UIScreenDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleExternalDisplay), name: .UIScreenDidDisconnect, object: nil)

        if #available(iOS 11.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(handleScreenCapture), name: .UIScreenCapturedDidChange, object: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopPeriodicAttemptUpdater()
        videoPlayerView.dealloc()
        NotificationCenter.default.removeObserver(self, name: .UIScreenDidConnect, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIScreenDidDisconnect, object: nil)
        
        if #available(iOS 11.0, *) {
            NotificationCenter.default.removeObserver(self, name: .UIScreenCapturedDidChange, object: nil)
        }

    }
    
    func showPlaybackSpeedMenu() {
        let alert = UIAlertController(title: "Playback Speed", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        PlaybackSpeed.allCases.forEach{ playbackSpeed in
            alert.addAction(UIAlertAction(title: playbackSpeed.rawValue, style: .default, handler: { (_) in
                self.videoPlayerView.changePlaybackSpeed(speed: playbackSpeed)
            }))
        }
        alert.popoverPresentationController?.sourceView = self.view
        self.present(alert, animated: true)
    }
}

extension VideoContentViewController: VideoPlayerDelegate {
    func changePlayBackSpeed() {
        showPlaybackSpeedMenu()
    }
}


extension UIWindow {
    func removeVideoPlayerView() {
        for subview in self.subviews {
            if subview is VideoPlayerView  {
               subview.removeFromSuperview()
            }
        }
    }
}

