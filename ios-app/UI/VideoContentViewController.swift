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
    @IBOutlet weak var videoPlayer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!

    
    let playerViewController = AVPlayerViewController()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let videoURL = URL(string: content.video!.url!)
        initializePlayer(videoURL: videoURL!)
        titleLabel.text = content.video?.title
        desc.text = content.description
    }
    
    func initializePlayer(videoURL: URL) {
        let player = AVPlayer(url: videoURL)
        player.rate = 1
        playerViewController.player = player
        addChildViewController(playerViewController)
        playerViewController.view.sizeToFit()
        view.addSubview(playerViewController.view)
        playerViewController.didMove(toParentViewController: self)
        handleOrientation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let playerFrame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.width, height: videoPlayer.frame.height)
        playerViewController.view.frame = playerFrame
        scrollView.contentSize.height = stackView.frame.size.height
    }

    
    func handleOrientation() {
        if UIDevice.current.orientation.isLandscape {
            playerViewController.enterFullScreen()
        } else {
            playerViewController.exitFullScreen()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        handleOrientation()
    }
    
}

extension AVPlayerViewController {
    
    func enterFullScreen() {
        let selectorName: String = {
            if #available(iOS 11.3, *) {
                return "_transitionToFullScreenAnimated:interactive:completionHandler:"
            } else if #available(iOS 11, *) {
                return "_transitionToFullScreenAnimated:completionHandler:"
            } else {
                return "_transitionToFullScreenViewControllerAnimated:completionHandler:"
            }
        }()
        let selector = NSSelectorFromString(selectorName)
        
        if self.responds(to: selector) {
            self.perform(selector, with: true, with: nil)
        }
    }
    
    func exitFullScreen() {
        let selectorName = "exitFullScreenAnimated:completionHandler:"
        let selector = NSSelectorFromString(selectorName)
        
        if self.responds(to: selector) {
            self.perform(selector, with: true, with: nil)
        }
    }
}
