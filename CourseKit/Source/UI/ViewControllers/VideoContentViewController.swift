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
import TTGSnackbar


class VideoContentViewController: BaseUIViewController,UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    var content: Content!
    var contents: [Content]!
    var playerViewController: VideoPlayerViewController!
    var viewModel: VideoContentViewModel!
    var customView: UIView!
    var warningLabel: UILabel!
    var bookmarkHelper: BookmarkHelper!
    var bookmarkDelegate: BookmarkDelegate?
    var bookmarkContent: Content?
    var position: Int! = 0
    
    @IBOutlet weak var videoPlayer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var desc: UITextView!
    @IBOutlet weak var titleToggleButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleStackView: UIStackView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = VideoContentViewModel(content)
        initalizePlayerViewController()
        videoPlayer.addSubview(playerViewController.view)
        viewModel.videoPlayerView = playerViewController.playerView
        showOrHideBottomBar()
        titleLabel.text = viewModel.getTitle()
        initializeDescription()
        bookmarkContent = content
        viewModel.createContentAttempt()
        udpateBookmarkButtonState(bookmarkId: content!.bookmarkId.value)
        bookmarkHelper = BookmarkHelper(viewController: self)
        bookmarkHelper.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        addGestures()
    }
    
    func initalizePlayerViewController(){
        let drmLicenseURL = content.video?.isDRMProtected == true ? TPEndpointProvider.getDRMLicenseURL(contentID: content.id) : nil
        playerViewController = VideoPlayerViewController(hlsURL: content.video!.getHlsUrl(), drmLicenseURL: drmLicenseURL)
        playerViewController.view.frame = videoPlayer.bounds
        addChild(playerViewController)
    }
    
    func initializeDescription() {
        desc.attributedText = parseVideoDescription()
        desc.isHidden = true
        desc.delegate = self
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
    
    func parseVideoDescription() -> NSMutableAttributedString? {
        let description = """
        <html>
          <head>
            <style>
              body {
                font-family: -apple-system;
                font-size: 16px;
              }
            </style>
          </head>
          <body>
            \(viewModel.getDescription())
          </body>
        </html>
        """

        let data = description.data(using: .utf8)!
        let urlAttribute = [
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16.0),
            NSAttributedString.Key.link: URL(string: "dummy_link")!,
        ] as [NSAttributedString.Key : Any]

        let attributedString = try? NSMutableAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil
            )

        let durationRegex = "([0-2]?[0-9]?:?[0-5]?[0-9]:[0-5][0-9])"
        let ranges = attributedString!.string.nsRanges(of: durationRegex, options: .regularExpression)
        for range in ranges {
            attributedString!.addAttributes(urlAttribute, range: range)
        }
        
        return attributedString
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
        
    func addOrRemoveBookmark(content: Content?) {
        bookmarkContent = content ?? self.content
        bookmarkHelper?.onClickBookmarkButton(bookmarkId: bookmarkContent?.bookmarkId.value)
    }
    
    
    func udpateBookmarkButtonState(bookmarkId: Int?) {
        if bookmarkContent?.id == content.id {
            DBManager<Content>().write {
                content.bookmarkId.value = bookmarkId
            }
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
                DBManager<Content>().write {
                    contents[cellContentId].bookmarkId.value = bookmarkId
                }
                tableView.reloadData()
            }
        }
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
        
        if let contentDetailPageViewController = self.parent?.parent as? ContentDetailPageViewController {
            contentDetailPageViewController.disableSwipeGesture()
            contentDetailPageViewController.hideNavbarTitle()
            contentDetailPageViewController.enableBookmarkOption()
        }
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateVideoAttempt), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @objc func updateVideoAttempt() {
        viewModel.updateVideoAttempt()
    }
    
    func changeVideo(content: Content!) {
        self.content = content
        DBManager<Content>().write {
            self.content.index = contents.firstIndex(where: { $0.id == content.id })!
        }
        viewModel.content = content
        hideDescription()
        viewModel.createContentAttempt()
        playerViewController.playerView.playVideo(url: URL(string: content.video!.getHlsUrl())!)
        tableView.reloadData()
        titleLabel.text = viewModel.getTitle()
        desc.text = viewModel.getDescription()
        titleStackView.layoutIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.updateVideoAttempt()

        if let contentDetailPageViewController = self.parent?.parent as? ContentDetailPageViewController {
            contentDetailPageViewController.disableSwipeGesture()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        desc.sizeToFit()
        
        if let tableHeaderView = tableView.tableHeaderView  {
            if !desc.isHidden && desc.text != nil {
                tableHeaderView.frame.size.height = titleStackView.frame.size.height + desc.frame.size.height + 20
            } else {
                tableHeaderView.frame.size.height = titleStackView.frame.size.height + 20
            }
            tableView.tableHeaderView = tableHeaderView
        }
        
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let duration = textView.text.substring(with: characterRange)
        if duration != nil {
            let seconds = TimeUtils.convertDurationStringToSeconds(durationString: String(duration!))
            playerViewController.playerView.goTo(seconds: Float(seconds))
        }
        return true
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
