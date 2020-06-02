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
        playVideo(url: url)
        playerLayer = AVPlayerLayer(player: player)
        self.layer.addSublayer(playerLayer!)
        playerLayer?.frame = self.frame
    }
    
    func playVideo(url: URL) {
        controlsContainerView.startLoading()
        self.url = url
        var urlComponents = URLComponents(
            url: url,
            resolvingAgainstBaseURL: false
        )!
        urlComponents.scheme = "fakehttps"
        do {
            let asset = try AVURLAsset(url: urlComponents.asURL())
            asset.resourceLoader.setDelegate(self, queue: DispatchQueue.main)
            let playerItem = AVPlayerItem(asset: asset)
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
        } catch {
            debugPrint("InCorrect URL Component")
        }
        
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
    
    func dealloc() {
        player?.pause()
        controlsContainerView.playerStatus = .paused
        player?.removeTimeObserver(timeObserver!)
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


extension VideoPlayerView: AVAssetResourceLoaderDelegate {
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {

        guard let url = loadingRequest.request.url else { return false }
        
        if url.scheme == "fakehttps" {
            var urlComponents = URLComponents(
                url: url,
                resolvingAgainstBaseURL: false
            )
            urlComponents!.scheme = "https"
            let newUrl =  urlComponents!.url
            loadAndModifyM3U8(videoUrl: newUrl!, loadingRequest: loadingRequest)
            return true
        } else if url.scheme == "fakekeyhttps" || url.path.contains("encryption_key") {
            var urlComponents = URLComponents(
                url: url,
                resolvingAgainstBaseURL: false
            )
            urlComponents!.scheme = "https"
            let newUrl = urlComponents!.url!
            
            let key: Data? = KeychainWrapper.standard.data(forKey: newUrl.absoluteString)
            if (key != nil) {
                loadHLSKey(loadingRequest: loadingRequest, key: key!)
            } else {
                loadAndStoreHLSKey(keyUrl: newUrl, loadingRequest: loadingRequest)
            }
            
            return true
        }
        return false
    }
    
    
    func loadAndModifyM3U8(videoUrl: URL, loadingRequest: AVAssetResourceLoadingRequest) {
        var request = URLRequest(url: videoUrl)
        request.httpMethod = "GET"
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request) { data, response, _ in
            guard let data = data else { return }
            var modifiedData: Data!
            var strData = String(data: data, encoding: .utf8)!

            if strData.contains("EXT-X-KEY") {
                strData = self.modifyKeyURL(m3u8Data: strData)
            }
            
            modifiedData = self.modifyVideoChunkURL(videoUrl: videoUrl, m3u8Data: strData)
            loadingRequest.contentInformationRequest?.contentType = response?.mimeType
            loadingRequest.contentInformationRequest?.isByteRangeAccessSupported = true
            loadingRequest.contentInformationRequest?.contentLength = response!.expectedContentLength
            loadingRequest.dataRequest?.respond(with: modifiedData)
            loadingRequest.finishLoading()
            
        }
        task.resume()
    }
    
    func modifyKeyURL(m3u8Data: String) -> String {
        /*
         Since we need to add authorization header to key url, we need to intercept key url.
         So we are changing schema of the key URL so that we can intercept it.
         */
        let start = m3u8Data.range(of: "URI=\"")!.upperBound
        let end = m3u8Data[start...].range(of: "\"")!.lowerBound
        let keyUrl = m3u8Data[start..<end]
        let newKeyUrl = keyUrl.replacingOccurrences(of: "https://", with: "fakekeyhttps://")
        return m3u8Data.replacingOccurrences(
            of: keyUrl,
            with: newKeyUrl
        )
    }
    
    func modifyVideoChunkURL(videoUrl: URL, m3u8Data: String) -> Data {
        /*
         Since video chunk urls will be relative paths, it will use url base as custom
         host "fakehttps". But we are don't need to intercept video chunks so we are changing it
         to absolute URL.
        */
        let path:NSString = videoUrl.path as NSString
        let customPath = path.deletingLastPathComponent
        let newKey = m3u8Data.replacingOccurrences(
            of: "(#EXTINF:[0-9]*,\n)", with: String(format: "$1 https://%@%@/", videoUrl.host!, customPath), options: .regularExpression
        )
        return newKey.data(using: .utf8)!
        
    }
    
    func loadAndStoreHLSKey(keyUrl: URL, loadingRequest: AVAssetResourceLoadingRequest) {
        var request = URLRequest(url: keyUrl)
        let token: String = KeychainTokenItem.getToken()
        request.setValue("JWT " + token, forHTTPHeaderField: "Authorization")
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request) { data, response, _ in
            KeychainWrapper.standard.set(data!, forKey: keyUrl.absoluteString)
            self.loadHLSKey(loadingRequest: loadingRequest, key: data!)
        }
        task.resume()
    }
    
    func loadHLSKey(loadingRequest: AVAssetResourceLoadingRequest, key: Data) {
        loadingRequest.contentInformationRequest?.contentType = AVStreamingKeyDeliveryPersistentContentKeyType
        loadingRequest.contentInformationRequest?.isByteRangeAccessSupported = true
        loadingRequest.contentInformationRequest?.contentLength = Int64(key.count)
        loadingRequest.dataRequest?.respond(with: key)
        loadingRequest.finishLoading()
    }
}
