//
//  VideoPlayerView.swift
//  ios-app
//
//  Created by Karthik raja on 12/4/19.
//  Copyright © 2019 Testpress. All rights reserved.
//

import UIKit
import AVKit
import M3U8Parser
import MarqueeLabel


public class VideoPlayerView: UIView {
    public var url: URL!
    public var drmLicenseURL: String?
    public var playerLayer: AVPlayerLayer?
    public var player: AVPlayer? = AVPlayer()
    public var playerDelegate: VideoPlayerDelegate!
    public var controlsContainerView: VideoPlayerControlsView! = .fromNib("VideoPlayerControls")
    public var timeObserver: Any?
    public var videoEndObserver: Any?
    public var startTime: Float = 0.0
    public var currentPlaybackSpeed: Float = 0.0
    public var resolutionInfo:[VideoQuality] = [VideoQuality(resolution:"Auto", bitrate: 0)]
    public var timer: Timer?
    public var watermarkLabel: MarqueeLabel?
    public var contentKeySessionDelegate: DRMKeySessionDelegate!
    public var videoPlayerResourceLoaderDelegate: VideoPlayerResourceLoaderDelegate!
    public var isLive: Bool = false {
        didSet {
            controlsContainerView.isLive = isLive
        }
    }
    
    public var videoDuration: CMTime {
        guard let currentItem = player?.currentItem else {
            return .invalid
        }

        if isLive {
            guard let seekableTimeRange = currentItem.seekableTimeRanges.last?.timeRangeValue else {
                return .invalid
            }
            return CMTime(seconds: seekableTimeRange.end.seconds, preferredTimescale: 1_000)
        } else {
            return currentItem.duration
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public init(frame: CGRect, url: URL, drmLicenseURL: String?) {
        self.url = url
        self.drmLicenseURL = drmLicenseURL
        self.contentKeySessionDelegate = DRMKeySessionDelegate(drmLicenseURL: drmLicenseURL)!
        self.videoPlayerResourceLoaderDelegate = VideoPlayerResourceLoaderDelegate()
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
    
    public func playVideo(url: URL) {
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

    public func createAVAssetWithCustomURLScheme() -> AVURLAsset {
        let modifiedURL = URLUtils.convertURLScheme(url: url, scheme: "fakehttps")
        let asset = AVURLAsset(url: modifiedURL)
        asset.resourceLoader.setDelegate(videoPlayerResourceLoaderDelegate, queue: DispatchQueue.main)
        if #available(iOS 11.0, *) {
            if drmLicenseURL != nil {
                let contentKeySession = AVContentKeySession(keySystem: AVContentKeySystem.fairPlayStreaming)
                contentKeySession.setDelegate(contentKeySessionDelegate, queue: DispatchQueue.main)
                contentKeySession.addContentKeyRecipient(asset)
                videoPlayerResourceLoaderDelegate.setContentKeySession(contentKeySession: contentKeySession)
            }
        }
        return asset
    }
    
    public func parseResolutionInfo() {
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
    
    public func addObservers() {
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
                self.controlsContainerView.updateDuration(seconds:seconds, videoDuration: self.videoDuration.seconds)
                self.controlsContainerView.updateLoadedDuration(seconds:loadedDuration)
            }
        })

    }
    
    public func initPlayer()  {
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
    
    public func deallocate() {
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
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
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
    
    public func changeBitrate(_ bitrate: Int) {
        player?.currentItem?.preferredPeakBitRate = Double(bitrate)
    }
    
    public func getCurrentBitrate() -> Double {
        return player?.currentItem?.preferredPeakBitRate ?? 0.0
    }
    
    public func getCurrenPlaybackSpeed() -> Float {
        return player?.rate ?? 1.0
    }
    
    public func changePlaybackSpeed(speed: PlaybackSpeed) {
        currentPlaybackSpeed = speed.value
        play()
    }
    
    public func pause() {
        player?.pause()
        controlsContainerView.playerStatus = .paused
    }
    
    public func play() {
        player?.rate = currentPlaybackSpeed
        controlsContainerView.playerStatus = .playing
    }
    
}


extension VideoPlayerView: PlayerControlDelegate {
    public func showOptionsMenu() {
        playerDelegate?.showOptionsMenu()
    }
    
    public func goTo(seconds: Float) {
        let seekTime = CMTime(value: Int64(seconds), timescale: 1)
        player?.seek(to: seekTime)
        
        if (controlsContainerView.playerStatus == .finished) {
            player?.play()
            controlsContainerView.playerStatus = .playing
        }
        startTime = seconds
    }
    
    public func playOrPause() {
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
    
    public func forward() {
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
    
    public func rewind() {
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
    
    public func fullScreen() {
        playerDelegate?.toggleFullScreen()
    }
    
    public func isPlaying() -> Bool {
        return player?.isPlaying ?? false
    }
}

public protocol VideoPlayerDelegate: class {
    func showOptionsMenu()
    func toggleFullScreen()
}

