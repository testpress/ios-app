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


class VideoContentViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    var content: Content!
    var contents: [Content]!
    var videoPlayerView: VideoPlayerView!
    var viewModel: VideoContentViewModel!
    var customView: UIView!
    var warningLabel: UILabel!
    var bookmarkHelper: BookmarkHelper!
    
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
        viewModel.createContentAttempt()
        addCustomView()
        desc.isHidden = true
        udpateBookmarkButtonState(bookmarkId: content.bookmarkId)
        
        
        tableView.dataSource = self
        tableView.delegate = self
        addGestures()
        
        handleExternalDisplay()
        if #available(iOS 11.0, *) {
            handleScreenCapture()
        }
        
    }
    
    
    func showOrHideDescription() {
        self.desc.isHidden = !self.desc.isHidden
        
        if (self.desc.isHidden) {
            self.titleToggleButton.setImage(Images.CaretDown.image, for: .normal)
        } else {
            self.titleToggleButton.setImage(Images.CaretUp.image, for: .normal)
        }
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
    
    func addOrRemoveBookmark() {
        if (content.bookmarkId != nil) {
            viewModel.removeBookmark(completion: {self.udpateBookmarkButtonState(bookmarkId: nil)})
        } else {
            bookmark()
        }
    }
    
    
    func udpateBookmarkButtonState(bookmarkId: Int?) {
        content.bookmarkId = bookmarkId
        tableView.reloadData()
        if let contentDetailPageViewController = self.parent?.parent as? ContentDetailPageViewController {
            if bookmarkId != nil {
                contentDetailPageViewController.navigationBarItem.rightBarButtonItem?.image = Images.RemoveBookmark.image
            } else {
                contentDetailPageViewController.navigationBarItem.rightBarButtonItem?.image = Images.AddBookmark.image
            }
        }
    }
    
    
    func bookmark() {
        let storyboard = UIStoryboard(name: Constants.BOOKMARKS_STORYBOARD, bundle: nil)
        let navigationController = storyboard.instantiateViewController(withIdentifier:
            Constants.BOOKMARK_FOLDER_NAVIGATION_CONTROLLER) as! UINavigationController
        
        let foldersTableViewController = navigationController.viewControllers.first
            as! BookmarkFolderTableViewController
        
        foldersTableViewController.sourceViewController = self
        present(navigationController, animated: true)
        
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
        videoPlayerView = VideoPlayerView(frame: playerFrame, url: URL(string: content.video!.url!)!)
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
        viewModel.startPeriodicAttemptUpdater()
        videoPlayerView.addObservers()
        
        if let contentDetailPageViewController = self.parent?.parent as? ContentDetailPageViewController {
            contentDetailPageViewController.disableSwipeGesture()
            contentDetailPageViewController.hideNavbarTitle()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleExternalDisplay), name: .UIScreenDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleExternalDisplay), name: .UIScreenDidDisconnect, object: nil)
        
        if #available(iOS 11.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(handleScreenCapture), name: .UIScreenCapturedDidChange, object: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopPeriodicAttemptUpdater()
        videoPlayerView.dealloc()
        NotificationCenter.default.removeObserver(self, name: .UIScreenDidConnect, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIScreenDidDisconnect, object: nil)
        
        if #available(iOS 11.0, *) {
            NotificationCenter.default.removeObserver(self, name: .UIScreenCapturedDidChange, object: nil)
        }
        
    }
    
    func showPlaybackSpeedMenu() {
        let alert = UIAlertController(title: "Playback Speed", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        PlaybackSpeed.allCases.forEach{ playbackSpeed in
            alert.addAction(UIAlertAction(title: playbackSpeed.rawValue, style: .default, handler: { (_) in
                self.videoPlayerView.changePlaybackSpeed(speed: playbackSpeed)
            }))
        }
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
    func changePlayBackSpeed() {
        showPlaybackSpeedMenu()
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

