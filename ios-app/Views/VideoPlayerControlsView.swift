//
//  VideoPlayerControlsView.swift
//  ios-app
//
//  Created by Karthik raja on 12/4/19.
//  Copyright © 2019 Testpress. All rights reserved.
//

import UIKit

class VideoPlayerControlsView: UIView {
    
    @IBOutlet weak var fullScreen: UIButton!
    @IBOutlet weak var rewindButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var currentDurationLabel: UILabel!
    @IBOutlet weak var totalDurationLabel: UILabel!
    @IBOutlet weak var playbackSpeed: UIButton!
    @IBOutlet weak var slider: VideoSlider!
    
    let TIMER_DELAY = 5.0
    var durationType = VideoDurationType.remainingTime
    weak var delegate: PlayerControlDelegate?
    var customConstraint: NSLayoutConstraint?
    var currentDuration: Double! = 0
    var totalDuration: Double! = 0
    var timer: Timer?
    var playerStatus: PlayerStatus = .readyToPlay {
        didSet {
            changeButtonStatus(playerStatus)
        }
    }

    
    func setUp() {
        self.isHidden = true
        self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        playerStatus = .playing
        self.addSubview(slider!)
        addGestureRecognizers()
        
    }
    
    func addGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(sliderTapped(gestureRecognizer:)))
        self.slider.addGestureRecognizer(tapGestureRecognizer)
        slider.addTarget(self, action: #selector(handleSliderChange), for: .valueChanged)
        
        self.addTapGestureRecognizer{
            self.timer?.invalidate()
            if !self.loadingIndicator.isAnimating && (self.playerStatus != .finished){
                self.isHidden = true
            }
        }
        
        totalDurationLabel.addTapGestureRecognizer {
            self.durationType = self.durationType == .totalTime ? .remainingTime : .totalTime
            self.totalDurationLabel.text = self.durationType.value(seconds: self.currentDuration, total: self.totalDuration)
        }
        
        playbackSpeed.addTapGestureRecognizer {
            self.delegate?.changePlayBackSpeed()
        }
    }
    
    func startTimerTohideControls() {
        self.timer?.invalidate()

        if (loadingIndicator.isAnimating) {
            return
        }
        
        if #available(iOS 10.0, *) {
            self.timer = Timer.scheduledTimer(withTimeInterval: TIMER_DELAY, repeats: false) { timer in
                self.isHidden = true
            }
        } else {
            self.timer = Timer.scheduledTimer(timeInterval: TIMER_DELAY, target: self, selector: #selector(self.hideControls), userInfo: nil, repeats: false)

        }
    }
    
    
    @objc func sliderTapped(gestureRecognizer: UIGestureRecognizer) {
        startTimerTohideControls()

        if (loadingIndicator.isAnimating) {
            return
        }

        let pointTapped: CGPoint = gestureRecognizer.location(in: self)
        let positionOfSlider: CGPoint = slider.frame.origin
        let widthOfSlider: CGFloat = slider.frame.size.width
        let newValue = (pointTapped.x - positionOfSlider.x) / widthOfSlider
        slider.currentPosition = Float(newValue)
        let seconds = Float64(slider!.currentPosition) * totalDuration
        delegate?.goTo(seconds: Float(seconds))
    }

    @objc func handleSliderChange() {
        startTimerTohideControls()

        if (loadingIndicator.isAnimating) {
            return
        }
        let seconds = Float64(slider!.currentPosition) * totalDuration
        delegate?.goTo(seconds: Float(seconds))
    }
    
    func showControls() {
        self.isHidden = false
    }
    
    @objc func hideControls() {
        self.isHidden = true
    }
    
    
    func startLoading() {
        self.isHidden = false
        rewindButton.isHidden = true
        forwardButton.isHidden = true
        playPauseButton.isHidden = true
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
    }
    
    func stopLoading() {
        if (loadingIndicator.isAnimating) {
            self.isHidden = true
            rewindButton.isHidden = false
            forwardButton.isHidden = false
            playPauseButton.isHidden = false
            loadingIndicator.stopAnimating()
            loadingIndicator.isHidden = true
        }
    }
    
    func updateLoadedDuration(seconds: Double) {
        slider.currentBuffer = Float(seconds/totalDuration)
    }
    
    func updateDuration(seconds: Double, videoDuration: Double) {
        stopLoading()
        slider.currentPosition = Float(seconds/videoDuration)
        totalDuration = videoDuration
        currentDuration = seconds
        totalDurationLabel.text = durationType.value(seconds: seconds, total: videoDuration)
        currentDurationLabel.text = durationType.getDurationString(seconds: seconds)
    }
    
    func changeButtonStatus(_ state: PlayerStatus) {
        startTimerTohideControls()
        
        switch state {
        case .readyToPlay:
            self.playPauseButton.setImage(Images.PauseIcon.image, for: .normal)
        case .playing:
            self.playPauseButton.setImage(Images.PauseIcon.image, for: .normal)
        case .paused:
            self.playPauseButton.setImage(Images.PlayIcon.image, for: .normal)
        case .finished:
            self.playPauseButton.setImage(Images.ReloadIcon.image, for: .normal)
        }
    }
    
    
    @IBAction func playPauseClick(_ sender: Any) {
        delegate?.playOrPause()
    }
    
    @IBAction func onFullscreen(_ sender: Any) {
        startTimerTohideControls()
        delegate?.fullScreen()
    }
    
    @IBAction func forward(_ sender: Any) {
        delegate?.forward()
    }
    
    @IBAction func rewind(_ sender: UIButton) {
        delegate?.rewind()
    }
}


protocol PlayerControlDelegate: class {
    func playOrPause()
    func forward()
    func rewind()
    func goTo(seconds:Float)
    func fullScreen()
    func changePlayBackSpeed()
}
