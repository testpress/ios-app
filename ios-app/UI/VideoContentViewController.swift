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
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleStackView: UIStackView!
    @IBOutlet weak var videoPlayer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var caretImage: UIImageView!
    @IBOutlet weak var contentView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = VideoContentViewModel(content)
        initAndSubviewPlayerViewController()
        titleLabel.text = viewModel.getTitle()
        desc.text = viewModel.getDescription()
        viewModel.createContentAttempt()
        addCustomView()
        udpateBookmarkButtonState(bookmarkId: content.bookmarkId)
        
        handleExternalDisplay()
        if #available(iOS 11.0, *) {
            handleScreenCapture()
        }

        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        
        
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
        if (content.bookmarkId != nil) {
            viewModel.removeBookmark(completion: {self.udpateBookmarkButtonState(bookmarkId: nil)})
        } else {
            bookmark()
        }
    }
    
    
    func udpateBookmarkButtonState(bookmarkId: Int?) {
        content.bookmarkId = bookmarkId
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
        super.viewDidLayoutSubviews()
        let playerFrame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.width, height: videoPlayer.frame.height)
        playerViewController.view.frame = playerFrame
        stackView.layoutIfNeeded()
        
        scrollView.contentSize.height = stackView.frame.height + tableView.contentSize.height + desc.frame.height + 300
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touch : \(touches)")
        if let touch = touches.first {
            let position = touch.location(in: view)
            print("Tableview Bounds \(touch.view)")
            if tableView.frame.contains(position) {
                print("I am in tableview")
            }
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



extension UIView {
    
    fileprivate struct AssociatedObjectKeys {
        static var tapGestureRecognizer = "MediaViewerAssociatedObjectKey_mediaViewer"
    }
    
    fileprivate typealias Action = (() -> Void)?
    
    fileprivate var tapGestureRecognizerAction: Action? {
        set {
            if let newValue = newValue {
                // Computed properties get stored as associated objects
                objc_setAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            let tapGestureRecognizerActionInstance = objc_getAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer) as? Action
            return tapGestureRecognizerActionInstance
        }
    }
    
    // This is the meat of the sauce, here we create the tap gesture recognizer and
    // store the closure the user passed to us in the associated object we declared above
    public func addTapGestureRecognizer(action: (() -> Void)?) {
        self.isUserInteractionEnabled = true
        self.tapGestureRecognizerAction = action
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // Every time the user taps on the UIImageView, this function gets called,
    // which triggers the closure we stored
    @objc fileprivate func handleTapGesture(sender: UITapGestureRecognizer) {
        if let action = self.tapGestureRecognizerAction {
            action?()
        } else {
            print("no action")
        }
    }
    
}

extension UIScrollView {
    func fitSizeOfContent() -> CGSize {
        let sumHeight = self.subviews.map({$0.frame.size.height}).reduce(0, {x, y in x + y})
                self.contentSize = CGSize(width: self.frame.width, height: sumHeight)
             return CGSize(width: self.frame.width, height: sumHeight)
    }
}
