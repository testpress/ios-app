//
//  VideoPlayerView.swift
//  ios-app
//
//  Created by Karthik raja on 12/4/19.
//  Copyright © 2019 Testpress. All rights reserved.
//

import UIKit
import AVKit
import M3U8KitDynamic
import SwiftKeychainWrapper
import MarqueeLabel


class VideoPlayerView: UIView {
    var url: URL!
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer? = AVPlayer()
    var playerDelegate: VideoPlayerDelegate!
    var controlsContainerView: VideoPlayerControlsView! = .fromNib("VideoPlayerControls")
    var timeObserver: Any?
    var videoEndObserver: Any?
    var startTime: Float = 0.0
    var currentPlaybackSpeed: Float = 0.0
    var resolutionInfo:[VideoQuality] = [VideoQuality(resolution:"Auto", bitrate: 0)]
    let videoPlayerResourceLoaderDelegate = VideoPlayerResourceLoaderDelegate()
    var timer: Timer?
    var watermarkLabel: MarqueeLabel?
    
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
        displayWatermark()
        addObservers()
        
        self.addTapGestureRecognizer {
            self.controlsContainerView.showControls()
            self.controlsContainerView.startTimerTohideControls()
        }
        controlsContainerView.startLoading()
    }
    
    
    private func setupPlayer() {
        backgroundColor = .black
        playVideo(url: url)
        playerLayer = AVPlayerLayer(player: player)
        self.layer.addSublayer(playerLayer!)
        playerLayer?.frame = self.frame
    }
    
    private func displayWatermark() {
        watermarkLabel = initializeWatermarkLabel()
        addSubview(watermarkLabel!)
    }
    
    private func initializeWatermarkLabel() -> MarqueeLabel {
        let watermarkLabel = MarqueeLabel.init(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 20), duration: 8.0, fadeLength: 0.0)
        watermarkLabel.text = KeychainTokenItem.getAccount().padding(toLength: Int((self.frame.width)/2), withPad: " ", startingAt: 0)
        watermarkLabel.numberOfLines = 1
        return watermarkLabel
    }
    
    
    @objc func moveWatermarkPosition() {
        watermarkLabel?.frame.origin.y = CGFloat(Int.random(in: 0..<Int(self.frame.height)))
    }
    
    func playVideo(url: URL) {
        controlsContainerView.startLoading()
        self.url = url
        let playerItem = AVPlayerItem(asset: createAVAssetWithCustomURLScheme())
        player?.replaceCurrentItem(with: playerItem)
        player?.seek(to: CMTime.zero)
        player?.rate = 1
        currentPlaybackSpeed = 1
        play()
        if #available(iOS 10.0, *) {
            player?.currentItem?.preferredForwardBufferDuration = 1
        }
        addObservers()
        parseResolutionInfo()
    }

    func createAVAssetWithCustomURLScheme() -> AVURLAsset {
        let modifiedURL = URLUtils.convertURLScheme(url: url, scheme: "fakehttps")
        let asset = AVURLAsset(url: modifiedURL)
        asset.resourceLoader.setDelegate(videoPlayerResourceLoaderDelegate, queue: DispatchQueue.main)
        return asset
    }
    
    func parseResolutionInfo() {
        do {
            resolutionInfo.removeAll()
            resolutionInfo = [VideoQuality(resolution:"Auto", bitrate: 0)]
            let playlistModel = try M3U8PlaylistModel(url: url)
            let masterPlaylist = playlistModel.masterPlaylist
            guard let streamList = masterPlaylist?.xStreamList else {
                return
            }
            streamList.sortByBandwidth(inOrder: .orderedAscending)
            
            for i in 0 ..< streamList.count {
                if let extXStreamInf = streamList.xStreamInf(at: i){
                    let resolution = "\(Int(extXStreamInf.resolution.height))p"
                    resolutionInfo.append(VideoQuality(resolution: resolution, bitrate: extXStreamInf.bandwidth))
                }
            }
        } catch {}
    }
    
    func addObservers() {
        initPlayer()
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(moveWatermarkPosition), userInfo: nil, repeats: true)
        player?.currentItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        player?.currentItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        player?.currentItem?.addObserver(self, forKeyPath: "playbackBufferFull", options: .new, context: nil)
        player?.currentItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        videoEndObserver = NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)

        
        let interval = CMTime(value: 1, timescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (progressTime) in
            let seconds = CMTimeGetSeconds(progressTime)
            if (self.player?.currentItem != nil) {
                let loadedDuration = CMTimeGetSeconds((self.player?.availableDuration())!)
                self.controlsContainerView.updateDuration(seconds:seconds, videoDuration: CMTimeGetSeconds((self.player?.currentItem?.duration)!))
                self.controlsContainerView.updateLoadedDuration(seconds:loadedDuration)
            }
        })

    }
    
    func initPlayer()  {
        if player != nil {
            player?.play()
            controlsContainerView.playerStatus = .playing
        } else {
            playVideo(url: self.url)
        }
    }
    
    @objc func playerDidFinishPlaying() {
        controlsContainerView.timer?.invalidate()
        controlsContainerView.showControls()
        controlsContainerView.playerStatus = .finished
    }
    
    func deallocate() {
        player?.pause()
        controlsContainerView.playerStatus = .paused
        player?.removeTimeObserver(timeObserver!)
        self.timer?.invalidate()
        NotificationCenter.default.removeObserver(videoEndObserver!)
        player?.currentItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        player?.currentItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        player?.currentItem?.removeObserver(self, forKeyPath: "playbackBufferFull")
        player?.currentItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
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
                        player?.currentItem?.preferredForwardBufferDuration = 0
                    }
                    controlsContainerView.stopLoading()
                case .none:
                    break;
                case .some(_):
                    break
            }
        }
    }
    
    func changeBitrate(_ bitrate: Int) {
        player?.currentItem?.preferredPeakBitRate = Double(bitrate)
    }
    
    func getCurrentBitrate() -> Double {
        return player?.currentItem?.preferredPeakBitRate ?? 0.0
    }
    
    func getCurrenPlaybackSpeed() -> Float {
        return player?.rate ?? 1.0
    }
    
    func changePlaybackSpeed(speed: PlaybackSpeed) {
        currentPlaybackSpeed = speed.value
        play()
    }
    
    func pause() {
        player?.pause()
        controlsContainerView.playerStatus = .paused
    }
    
    func play() {
        player?.rate = currentPlaybackSpeed
        controlsContainerView.playerStatus = .playing
    }
    
}


extension VideoPlayerView: PlayerControlDelegate {
    func showOptionsMenu() {
        playerDelegate?.showOptionsMenu()
    }
    
    func goTo(seconds: Float) {
        let seekTime = CMTime(value: Int64(seconds), timescale: 1)
        player?.seek(to: seekTime)
        
        if (controlsContainerView.playerStatus == .finished) {
            player?.play()
            controlsContainerView.playerStatus = .playing
        }
        startTime = seconds
    }
    
    func playOrPause() {
        if (controlsContainerView.playerStatus == .finished) {
            player?.currentItem?.seek(to: CMTime.zero, completionHandler: { _ in
                self.play()
            })
        } else {
            if (player?.isPlaying)! {
                self.pause()
            } else {
                self.play()
            }
        }
    }
    
    func forward() {
        guard let duration  = player?.currentItem?.asset.duration else{
            return
        }
        let playerCurrentTime = CMTimeGetSeconds((player?.currentItem!.currentTime())!)
        let newTime = playerCurrentTime + 10
        
        if newTime < (CMTimeGetSeconds(duration)) {
            let seekTime: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
            player?.seek(to: seekTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
            startTime = Float(newTime)
            
        }
        
    }
    
    func rewind() {
        let playerCurrentTime = CMTimeGetSeconds((player?.currentTime())!)
        var newTime = playerCurrentTime - 10
        
        if newTime < 0 {
            newTime = 0
        }
        let seekTime: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
        player?.seek(to: seekTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        startTime = Float(newTime)
        
        if (controlsContainerView.playerStatus == .finished) {
            player?.play()
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
    
    func isPlaying() -> Bool {
        return player?.isPlaying ?? false
    }
}

protocol VideoPlayerDelegate: class {
    func showOptionsMenu()
}

