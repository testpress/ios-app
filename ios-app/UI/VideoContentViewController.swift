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


class VideoContentViewController: UIViewController {
    var content: Content!
    var videoPlayerView: VideoPlayerView!

    @IBOutlet weak var videoPlayer: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initVideoPlayerView()
        view.addSubview(videoPlayerView)
        showOrHideBottomBar()
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
        videoPlayerView.layoutIfNeeded()
        videoPlayerView.playerLayer?.frame = playerFrame
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        handleFullScreen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        videoPlayerView.addObservers()

        if let contentDetailPageViewController = self.parent?.parent as? ContentDetailPageViewController {
            contentDetailPageViewController.disableSwipeGesture()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        videoPlayerView.dealloc()
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

