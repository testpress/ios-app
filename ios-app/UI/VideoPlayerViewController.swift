//
//  VideoPlayerViewController.swift
//  ios-app
//
//  Created by Testpress on 21/05/24.
//  Copyright © 2024 Testpress. All rights reserved.
//

import Foundation
import UIKit
import CourseKit

class VideoPlayerViewController: UIViewController {
    var playerView: VideoPlayerView!
    var warningLabel: UILabel!
    var warningView: UIView!
    var hlsURL: String!
    var drmLicenseURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initVideoPlayerView()
        view.addSubview(playerView)
        addWarningView()
        
        handleExternalDisplay()
        if #available(iOS 11.0, *) {
            handleScreenCapture()
        }
    }
    
    init(hlsURL: String, drmLicenseURL: String?) {
        self.hlsURL = hlsURL
        self.drmLicenseURL = drmLicenseURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func initVideoPlayerView() {
        playerView = VideoPlayerView(frame: view.bounds, url: URL(string: self.hlsURL)!, drmLicenseURL: drmLicenseURL)
        playerView.playerDelegate = self
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleExternalDisplay), name: UIScreen.didConnectNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleExternalDisplay), name: UIScreen.didDisconnectNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)

        
        if #available(iOS 11.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(handleScreenCapture), name: UIScreen.capturedDidChangeNotification, object: nil)
        }
    }
    
    func addWarningView() {
        warningLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        warningLabel.textColor = UIColor.white
        warningLabel.textAlignment = .center
        warningLabel.numberOfLines = 3
        
        warningView = UIView(frame: view.bounds)
        warningView.backgroundColor = UIColor.black
        warningView.center = CGPoint(x: view.center.x, y: view.center.y)
        warningLabel.center = warningView.center
        warningView.addSubview(warningLabel)
        warningView.isHidden = true
        view.addSubview(warningView)
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
    
    @objc func willEnterForeground() {
        playerView.play()
    }
    
    func showWarning(text: String) {
        playerView.pause()
        playerView.isHidden = true
        warningLabel.text = text
        warningLabel.sizeToFit()
        warningView.isHidden = false
    }
    
    
    func hideWarning() {
        playerView.isHidden = false
        warningView.isHidden = true
    }
    
    func showPlaybackSpeedMenu() {
        var alert: UIAlertController!
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            alert = UIAlertController(title: "Playback Speed", message: nil, preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: "Playback Speed", message: nil, preferredStyle: .actionSheet)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        PlaybackSpeed.allCases.forEach{ playbackSpeed in
            let action = UIAlertAction(title: playbackSpeed.rawValue, style: .default, handler: { (_) in
                self.playerView.changePlaybackSpeed(speed: playbackSpeed)
            })
            if (playbackSpeed.value == self.playerView.getCurrenPlaybackSpeed()){
                action.setValue(Images.TickIcon.image, forKey: "image")
            } else if(self.playerView.getCurrenPlaybackSpeed() == 0.0 && playbackSpeed == .normal) {
                action.setValue(Images.TickIcon.image, forKey: "image")
            }
            
            alert.addAction(action)
        }
        alert.popoverPresentationController?.sourceView = self.view
        self.present(alert, animated: true)
    }
    
    func showQualitySelector() {
        var alert: UIAlertController!
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            alert = UIAlertController(title: "Quality", message: nil, preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: "Quality", message: nil, preferredStyle: .actionSheet)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        for resolutionInfo in playerView.resolutionInfo {
            let action = UIAlertAction(title: resolutionInfo.resolution, style: .default, handler: { (_) in
                self.playerView.changeBitrate(resolutionInfo.bitrate)
            })
            
            if (Double(resolutionInfo.bitrate) == playerView.getCurrentBitrate()) {
                action.setValue(Images.TickIcon.image, forKey: "image")
            }
            alert.addAction(action)
        }
        alert.popoverPresentationController?.sourceView = self.view
        self.present(alert, animated: true)
    }
    
    func displayOptions() {
        var alert: UIAlertController!
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Playback Speed", style: .default, handler: { _ in
            self.showPlaybackSpeedMenu()
        }))
        alert.addAction(UIAlertAction(title: "Video Quality", style: .default, handler: { _ in
            self.showQualitySelector()
        }))
        alert.popoverPresentationController?.sourceView = self.view
        self.present(alert, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        playerView.deallocate()

        NotificationCenter.default.removeObserver(self, name: UIScreen.didConnectNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIScreen.didDisconnectNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)        
        if #available(iOS 11.0, *) {
            NotificationCenter.default.removeObserver(self, name: UIScreen.capturedDidChangeNotification, object: nil)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        warningView.frame = view.bounds
        handleFullScreen()
    }
    
    func handleFullScreen() {
        var playerFrame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        UIApplication.shared.keyWindow?.removeVideoPlayerView()
        view.addSubview(playerView)
        
        if (getCurrentOrientation().isLandscape) {
            playerFrame = UIScreen.main.bounds
            UIApplication.shared.keyWindow!.addSubview(playerView)
        }
        playerView.frame = playerFrame
        warningLabel.center = warningView.center
        playerView.layoutIfNeeded()
        warningView.layoutIfNeeded()
        playerView.playerLayer?.frame = playerFrame
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
        playerView.addObservers()
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


extension VideoPlayerViewController: VideoPlayerDelegate {
    func showOptionsMenu() {
        displayOptions()
    }
    
    func toggleFullScreen() {
        if getCurrentOrientation().isLandscape {
            changeDeviceOrientation(orientation: .portrait)
        } else {
            changeDeviceOrientation(orientation: .landscapeRight)
        }
                                 
    }
    
    func changeDeviceOrientation(orientation: UIInterfaceOrientationMask) {
        if #available(iOS 16.0, *) {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: orientation))
        } else {
            UIDevice.current.setValue(orientation.toUIInterfaceOrientation.rawValue, forKey: "orientation")
        }
    }
}
