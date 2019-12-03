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


class VideoContentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var content: Content!
    var contents: [Content]!
    var playerViewController:AVPlayerViewController!
    var viewModel: VideoContentViewModel!
    var customView: UIView!
    var warningLabel: UILabel!
    var bookmarkHelper: BookmarkHelper!
    var bookmarkDelegate: BookmarkDelegate?
    var bookmarkContent: Content?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleStackView: UIStackView!
    @IBOutlet weak var videoPlayer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var caretImage: UIImageView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var headerStackView: UIStackView!
    @IBOutlet weak var headerView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = VideoContentViewModel(content)
        initAndSubviewPlayerViewController()
        titleLabel.text = viewModel.getTitle()
        desc.text = viewModel.getDescription()
        viewModel.createContentAttempt()
        addCustomView()
        desc.isHidden = true
        udpateBookmarkButtonState(bookmarkId: content.bookmarkId)
        bookmarkHelper = BookmarkHelper(viewController: self)
        bookmarkHelper.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        addGestures()
        
        handleExternalDisplay()
        if #available(iOS 11.0, *) {
            handleScreenCapture()
        }
        
    }
    

    func addGestures() {
        titleStackView.addTapGestureRecognizer {
            self.desc.isHidden = !self.desc.isHidden
            
            if (self.desc.isHidden) {
                self.caretImage.image = Images.CaretDown.image
            } else {
                self.caretImage.image = Images.CaretUp.image
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RelatedContentsCell", for: indexPath) as! RelatedContentsCell
        
        cell.initCell(index: indexPath.row, contents: contents, viewController: self, is_current: content.id == contents[indexPath.row].id)
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
    
    func addOrRemoveBookmark() {
        bookmarkHelper?.onClickBookmarkButton(bookmarkId: content.bookmarkId)
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
        viewModel.handleOrientation()
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
        let headerHeight = headerView.fitSizeOfContent().height - desc.frame.size.height
        
        super.viewDidLayoutSubviews()
        let playerFrame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.width, height: videoPlayer.frame.height)
        playerViewController.view.frame = playerFrame
        desc.sizeToFit()
        
        if let tableHeaderView = tableView.tableHeaderView  {
            if !desc.isHidden && desc.text != nil {
                tableHeaderView.frame.size.height = titleStackView.frame.size.height + desc.frame.size.height + 20
            } else {
                tableHeaderView.frame.size.height = headerHeight
            }
            
            tableView.tableHeaderView = tableHeaderView
            tableView.layoutIfNeeded()
        }
        
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        viewModel.handleOrientation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        playerViewController.player?.pause()
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
        parameters["object_id"] = content.id
        parameters["content_type"] = ["model": "chaptercontent", "app_label": "courses"]
        return parameters
    }
    
    func updateBookmark(bookmarkId: Int?) {
        self.udpateBookmarkButtonState(bookmarkId: bookmarkId)
    }
}
