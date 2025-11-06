//
//  VideoPlayerControlsView.swift
//  ios-app
//
//  Created by Karthik raja on 12/4/19.
//  Copyright © 2019 Testpress. All rights reserved.
//

import UIKit

public class VideoPlayerControlsView: UIView {
    
    @IBOutlet weak var fullScreen: UIButton!
    @IBOutlet weak var rewindButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var currentDurationLabel: UILabel!
    @IBOutlet weak var totalDurationLabel: UILabel!
    @IBOutlet weak var slider: VideoSlider!
    @IBOutlet weak var optionsButton: UIButton!
    
    @IBOutlet weak var liveLabelContainer: UIView!
    
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
    var isLive: Bool = false {
        didSet {
            if(isLive){
                totalDurationLabel.isHidden = true
                liveLabelContainer.isHidden = false
                setupLiveLabelView()
            }
        }
    }
    
    private let dotView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        return view
    }()

    private let liveLabel: UILabel = {
        let label = UILabel()
        label.text = "LIVE"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    
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
        
        
        optionsButton.addTapGestureRecognizer {
            self.delegate?.showOptionsMenu();
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
        delegate?.pause()
        delegate?.goTo(seconds: Float(seconds))
        slider.currentPosition = Float(seconds/totalDuration)
        delegate?.play()
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
        fullScreen.isHidden = true
        currentDurationLabel.isHidden = true
        totalDurationLabel.isHidden = true
        slider.isHidden = true
        optionsButton.isHidden = true
        loadingIndicator.startAnimating()
        liveLabelContainer.isHidden = true
    }
    
    func stopLoading() {
        if (loadingIndicator.isAnimating) {
            self.isHidden = true
            rewindButton.isHidden = false
            forwardButton.isHidden = false
            playPauseButton.isHidden = false
            currentDurationLabel.isHidden = false
            fullScreen.isHidden = false
            slider.isHidden = false
            optionsButton.isHidden = false
            if isLive {
                liveLabelContainer.isHidden = false
            } else {
                totalDurationLabel.isHidden = false
            }
            
            loadingIndicator.stopAnimating()
            loadingIndicator.isHidden = true
        }
    }
    
    func updateLoadedDuration(seconds: Double) {
        slider.currentBuffer = Float(seconds/totalDuration)
    }
    
    func updateDuration(seconds: Double, videoDuration: Double) {
        stopLoading()
        
        if(!(delegate?.isPlaying())!) {
            return
        }
        
        if (slider.isHighlighted) {
            timer?.invalidate()
        } else {
            slider.currentPosition = Float(seconds/videoDuration)
        }
 
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
    
    private func setupLiveLabelView() {
        liveLabelContainer.addSubview(dotView)
        liveLabelContainer.addSubview(liveLabel)
        liveLabelContainer.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            dotView.widthAnchor.constraint(equalToConstant: 8),
            dotView.heightAnchor.constraint(equalToConstant: 8),
            dotView.leadingAnchor.constraint(equalTo: liveLabelContainer.leadingAnchor),
            dotView.centerYAnchor.constraint(equalTo: liveLabelContainer.centerYAnchor),


            liveLabel.leadingAnchor.constraint(equalTo: dotView.trailingAnchor, constant: 5),
            liveLabel.centerYAnchor.constraint(equalTo: liveLabelContainer.centerYAnchor),
            liveLabel.trailingAnchor.constraint(equalTo: liveLabelContainer.trailingAnchor)
        ])
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


public protocol PlayerControlDelegate: class {
    func isPlaying() -> Bool
    func pause()
    func play()
    func playOrPause()
    func forward()
    func rewind()
    func goTo(seconds:Float)
    func fullScreen()
    func showOptionsMenu()
}
