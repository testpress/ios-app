//
//  VideoPlayerView.swift
//  ios-app
//
//  Created by Karthik raja on 12/4/19.
//  Copyright © 2019 Testpress. All rights reserved.
//

import UIKit
import AVKit

class VideoPlayerView: UIView {
    var url: URL!
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer!
    var playerDelegate: VideoPlayerDelegate!
    var controlsContainerView: VideoPlayerControlsView! = .fromNib("VideoPlayerControls")
    var timeObserver: Any?
    var videoEndObserver: Any?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, url: URL) {
        self.url = url
        super.init(frame: frame)
        setupPlayer()
        controlsContainerView.frame = frame
        controlsContainerView.delegate = self
        controlsContainerView.setUp()
        addSubview(controlsContainerView)
        addObservers()
        
        self.addTapGestureRecognizer {
            self.controlsContainerView.showControls()
            self.controlsContainerView.startTimerTohideControls()
        }
        controlsContainerView.startLoading()
    }
    
    
    private func setupPlayer() {
        backgroundColor = .black
        player = AVPlayer(url: url!)
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])
        player.rate = 1
        playerLayer = AVPlayerLayer(player: player)
        self.layer.addSublayer(playerLayer!)
        playerLayer?.frame = self.frame
        player.play()
        
        if #available(iOS 10.0, *) {
            player.currentItem?.preferredForwardBufferDuration = 1
        }
    }
    
    
    func addObservers() {
        player?.play()
        player?.currentItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        player?.currentItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        player?.currentItem?.addObserver(self, forKeyPath: "playbackBufferFull", options: .new, context: nil)
        player?.currentItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        videoEndObserver = NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)

        
        let interval = CMTime(value: 1, timescale: 2)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (progressTime) in
            let seconds = CMTimeGetSeconds(progressTime)
            self.controlsContainerView.updateDuration(seconds:seconds, videoDuration: CMTimeGetSeconds((self.player?.currentItem?.duration)!))
        })

    }
    
    
    @objc func playerDidFinishPlaying() {
        controlsContainerView.timer?.invalidate()
        controlsContainerView.showControls()
        controlsContainerView.playerStatus = .finished
    }
    
    func dealloc() {
        player.pause()
        controlsContainerView.playerStatus = .paused
        player?.currentItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        player?.currentItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        player?.currentItem?.removeObserver(self, forKeyPath: "playbackBufferFull")
        player?.currentItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        player.removeTimeObserver(timeObserver!)
        NotificationCenter.default.removeObserver(videoEndObserver!)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object is AVPlayerItem {
            switch keyPath {
                case "playbackBufferEmpty":
                    controlsContainerView.startLoading()
                case "playbackLikelyToKeepUp":
                    controlsContainerView.stopLoading()
                case "playbackBufferFull":
                    if #available(iOS 10.0, *) {
                        player.currentItem?.preferredForwardBufferDuration = 0
                    }
                    controlsContainerView.stopLoading()
                case .none:
                    break;
                case .some(_):
                    break
            }
        }
    }
    
    func changePlaybackSpeed(speed: PlaybackSpeed) {
        player.rate = speed.value
        controlsContainerView.playbackSpeed.setTitle(speed.label, for: .normal)
        controlsContainerView.playerStatus = .playing
    }
    
}


extension VideoPlayerView: PlayerControlDelegate {
    func changePlayBackSpeed() {
        playerDelegate?.changePlayBackSpeed()
    }
    
    func goTo(seconds: Float) {
        let seekTime = CMTime(value: Int64(seconds), timescale: 1)
        player?.seek(to: seekTime)
        
        if (controlsContainerView.playerStatus == .finished) {
            player?.play()
            controlsContainerView.playerStatus = .playing
        }
    }
    
    func playOrPause() {
        if (controlsContainerView.playerStatus == .finished) {
            player?.seek(to: kCMTimeZero, completionHandler: { _ in
                self.player.play()
                self.controlsContainerView.playerStatus = .playing
            })
        } else {
            if player.isPlaying {
                player.pause()
                controlsContainerView.playerStatus = .paused
            } else {
                player.play()
                controlsContainerView.playerStatus = .playing
            }
        }
    }
    
    func forward() {
        guard let duration  = player.currentItem?.asset.duration else{
            return
        }
        let playerCurrentTime = CMTimeGetSeconds(player.currentItem!.currentTime())
        let newTime = playerCurrentTime + 10
        
        if newTime < (CMTimeGetSeconds(duration)) {
            let seekTime: CMTime = CMTimeMake(Int64(newTime * 1000 as Float64), 1000)
            player.seek(to: seekTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
            
        }
        
    }
    
    func rewind() {
        let playerCurrentTime = CMTimeGetSeconds(player.currentTime())
        var newTime = playerCurrentTime - 10
        
        if newTime < 0 {
            newTime = 0
        }
        let seekTime: CMTime = CMTimeMake(Int64(newTime * 1000 as Float64), 1000)
        player.seek(to: seekTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)

        if (controlsContainerView.playerStatus == .finished) {
            player.play()
            controlsContainerView.playerStatus = .playing
        }
    }
    
    func fullScreen() {
        var value = UIInterfaceOrientation.landscapeRight.rawValue

        if UIDevice.current.orientation.isLandscape {
            value = UIInterfaceOrientation.portrait.rawValue
        }
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
}

protocol VideoPlayerDelegate: class {
    func changePlayBackSpeed()
}
