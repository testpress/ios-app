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
    var customView: UIView!
    var warningLabel: UILabel!
    
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
        
        customView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: videoPlayer.frame.height))
        customView.backgroundColor = UIColor.black
        customView.center = CGPoint(x: view.center.x, y: videoPlayer.center.y)
        warningLabel.center = customView.center
        customView.addSubview(warningLabel)
        customView.isHidden = true
        self.view.addSubview(customView)
    }
    
    func showWarning(text: String) {
        playerViewController.player?.pause()
        warningLabel.text = text
        warningLabel.sizeToFit()
        customView.isHidden = false
    }
    
    func hideWarning() {
        playerViewController.player?.play()
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
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath  == "rate" {
            viewModel.startTime = String(format: "%.4f", playerViewController.player!.currentTimeInSeconds)
        }
        
    }
    
    func initAndSubviewPlayerViewController() {
        playerViewController = viewModel.initializePlayer()
        addChildViewController(playerViewController)
        view.addSubview(playerViewController.view)
        playerViewController.didMove(toParentViewController: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.startPeriodicAttemptUpdater()
        playerViewController.player?.addObserver(self, forKeyPath: "rate", options: [.new, .initial], context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleExternalDisplay), name: .UIScreenDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleExternalDisplay), name: .UIScreenDidDisconnect, object: nil)

        if #available(iOS 11.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(handleScreenCapture), name: .UIScreenCapturedDidChange, object: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopPeriodicAttemptUpdater()
        playerViewController.player?.removeObserver(self, forKeyPath: "rate")
        NotificationCenter.default.removeObserver(self, name: .UIScreenDidConnect, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIScreenDidDisconnect, object: nil)
        
        if #available(iOS 11.0, *) {
            NotificationCenter.default.removeObserver(self, name: .UIScreenCapturedDidChange, object: nil)
        }

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var playerFrame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.width, height: videoPlayer.frame.height)
        
        if (UIDevice.current.orientation.isLandscape) {
            playerFrame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.width, height: view.frame.height)
        }
        
        playerViewController.view.frame = playerFrame
        scrollView.contentSize.height = stackView.frame.size.height
    }
    
}
