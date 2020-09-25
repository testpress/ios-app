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
import TTGSnackbar
import RealmSwift


class VideoContentViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    var content: Content!
    var contents: [Content]!
    var videoPlayerView: VideoPlayerView!
    var viewModel: VideoContentViewModel!
    var customView: UIView!
    var warningLabel: UILabel!
    var bookmarkHelper: BookmarkHelper!
    var bookmarkDelegate: BookmarkDelegate?
    var bookmarkContent: Content?
    var position: Int! = 0
    
    @IBOutlet weak var videoPlayer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var titleToggleButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleStackView: UIStackView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = VideoContentViewModel(content)
        initVideoPlayerView()
        view.addSubview(videoPlayerView)
        viewModel.videoPlayerView = videoPlayerView
        showOrHideBottomBar()
        titleLabel.text = viewModel.getTitle()
        desc.text = viewModel.getDescription()
        bookmarkContent = content
        viewModel.createContentAttempt()
        addCustomView()
        desc.isHidden = true
        udpateBookmarkButtonState(bookmarkId: content!.bookmarkId.value)
        bookmarkHelper = BookmarkHelper(viewController: self)
        bookmarkHelper.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        addGestures()
        
        handleExternalDisplay()
        if #available(iOS 11.0, *) {
            handleScreenCapture()
        }
        
        var value = UIInterfaceOrientation.landscapeRight.rawValue
          UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    
    func showOrHideDescription() {
        if (self.desc.isHidden) {
            showDescription()
        } else {
            hideDescription()
        }
    }
    
    func showDescription() {
        self.desc.isHidden = false
        self.titleToggleButton.setImage(Images.CaretUp.image, for: .normal)
    }
    
    func hideDescription() {
        self.desc.isHidden = true
        self.titleToggleButton.setImage(Images.CaretDown.image, for: .normal)
    }
    
    
    func addGestures() {
        titleStackView.addTapGestureRecognizer {
            self.showOrHideDescription()
        }
        
        titleToggleButton.addTapGestureRecognizer{
            self.showOrHideDescription()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RelatedContentsCell", for: indexPath) as! RelatedContentsCell
        
        cell.initCell(index: indexPath.row, contents: contents!, viewController: self, is_current: content.id == contents[indexPath.row].id)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func addCustomView() {
        warningLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        warningLabel.textColor = UIColor.white
        warningLabel.textAlignment = .center
        warningLabel.numberOfLines = 3
        
        customView = UIView(frame: videoPlayerView.frame)
        customView.backgroundColor = UIColor.black
        customView.center = CGPoint(x: view.center.x, y: videoPlayerView.center.y)
        warningLabel.center = customView.center
        customView.addSubview(warningLabel)
        customView.isHidden = true
        view.addSubview(customView)
    }
    
    func showWarning(text: String) {
        videoPlayerView.pause()
        videoPlayerView.isHidden = true
        warningLabel.text = text
        warningLabel.sizeToFit()
        customView.isHidden = false
    }
    
    func addOrRemoveBookmark(content: Content?) {
        bookmarkContent = content ?? self.content
        bookmarkHelper?.onClickBookmarkButton(bookmarkId: bookmarkContent?.bookmarkId.value)
    }
    
    
    func udpateBookmarkButtonState(bookmarkId: Int?) {
        if bookmarkContent?.id == content.id {
            content.bookmarkId = RealmOptional<Int>(bookmarkId)
            tableView.reloadData()
            if let contentDetailPageViewController = self.parent?.parent as? ContentDetailPageViewController {
                if bookmarkId != nil {
                    contentDetailPageViewController.navigationBarItem.rightBarButtonItem?.image = Images.RemoveBookmark.image
                } else {
                    contentDetailPageViewController.navigationBarItem.rightBarButtonItem?.image = Images.AddBookmark.image
                }
            }
        } else {
            if let cellContentId = contents.firstIndex(where: { $0.id == bookmarkContent?.id }) {
                contents[cellContentId].bookmarkId = RealmOptional<Int>(bookmarkId)
                tableView.reloadData()
            }
        }
    }
    
    
    func hideWarning() {
        videoPlayerView.isHidden = false
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
    
    func initVideoPlayerView() {
        let playerFrame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.width, height: videoPlayer.frame.height)
        videoPlayerView = VideoPlayerView(frame: playerFrame, url: URL(string: content.video!.getHlsUrl())!)
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
        customView.frame = videoPlayerView.frame
        videoPlayerView.layoutIfNeeded()
        videoPlayerView.playerLayer?.frame = playerFrame
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
        videoPlayerView.addObservers()
        
        if let contentDetailPageViewController = self.parent?.parent as? ContentDetailPageViewController {
            contentDetailPageViewController.disableSwipeGesture()
            contentDetailPageViewController.hideNavbarTitle()
            contentDetailPageViewController.enableBookmarkOption()
        }
        
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleExternalDisplay), name: UIScreen.didConnectNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleExternalDisplay), name: UIScreen.didDisconnectNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateVideoAttempt), name: UIApplication.willResignActiveNotification, object: nil)

        
        if #available(iOS 11.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(handleScreenCapture), name: UIScreen.capturedDidChangeNotification, object: nil)
        }
    }
    
    @objc func updateVideoAttempt() {
        viewModel.updateVideoAttempt()
    }
    
    @objc func willEnterForeground() {
        videoPlayerView.play()
    }
    
    func changeVideo(content: Content!) {
        self.content = content
        try! Realm().write {
            self.content.index = contents.firstIndex(where: { $0.id == content.id })!
        }
        videoPlayerView.fullScreen()
        videoPlayerView.fullScreen()
        viewModel.content = content
        hideDescription()
        viewModel.createContentAttempt()
        videoPlayerView.playVideo(url: URL(string: content.video!.getHlsUrl())!)
        tableView.reloadData()
        titleLabel.text = viewModel.getTitle()
        desc.text = viewModel.getDescription()
        titleStackView.layoutIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.updateVideoAttempt()
        videoPlayerView.dealloc()

        if let contentDetailPageViewController = self.parent?.parent as? ContentDetailPageViewController {
            contentDetailPageViewController.disableSwipeGesture()
        }

        NotificationCenter.default.removeObserver(self, name: UIScreen.didConnectNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIScreen.didDisconnectNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)

        
        if #available(iOS 11.0, *) {
            NotificationCenter.default.removeObserver(self, name: UIScreen.capturedDidChangeNotification, object: nil)
        }
        
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
                self.videoPlayerView.changePlaybackSpeed(speed: playbackSpeed)
            })
            if (playbackSpeed.value == self.videoPlayerView.getCurrenPlaybackSpeed()){
                action.setValue(Images.TickIcon.image, forKey: "image")
            } else if(self.videoPlayerView.getCurrenPlaybackSpeed() == 0.0 && playbackSpeed == .normal) {
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
        
        for resolutionInfo in videoPlayerView.resolutionInfo {
            let action = UIAlertAction(title: resolutionInfo.resolution, style: .default, handler: { (_) in
                self.videoPlayerView.changeBitrate(resolutionInfo.bitrate)
            })
            
            if (Double(resolutionInfo.bitrate) == videoPlayerView.getCurrentBitrate()) {
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        desc.sizeToFit()
        handleFullScreen()
        
        if let tableHeaderView = tableView.tableHeaderView  {
            if !desc.isHidden && desc.text != nil {
                tableHeaderView.frame.size.height = titleStackView.frame.size.height + desc.frame.size.height + 20
            } else {
                tableHeaderView.frame.size.height = titleStackView.frame.size.height + 20
            }
            tableView.tableHeaderView = tableHeaderView
        }
        
    }
}

extension VideoContentViewController: VideoPlayerDelegate {
    func showOptionsMenu() {
        displayOptions()
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


extension VideoContentViewController: BookmarkDelegate {
    func displayMoveButton() {

    }
    
    func displayBookmarkButton() {
    }
    
    func onClickMoveButton() {
    
    }
    
    func removeBookmark() {
    
    }
    
    func displayRemoveButton() {
        
    }
    
    func onClickBookmarkButton() {
    
    }
    
    func getBookMarkParams() -> Parameters? {
        var parameters: Parameters = Parameters()
        parameters["object_id"] = bookmarkContent?.id
        parameters["content_type"] = ["model": "chaptercontent", "app_label": "courses"]
        return parameters
    }
    
    func updateBookmark(bookmarkId: Int?) {
        self.udpateBookmarkButtonState(bookmarkId: bookmarkId)
    }
}
