//
//  BookmarksDetailPageViewController.swift
//  ios-app
//
//  Copyright © 2017 Testpress. All rights reserved.
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

class BookmarksDetailPageViewController: BaseUIViewController, UIPageViewControllerDelegate {
    
    @IBOutlet weak var questionsContainerView: UIView!
    @IBOutlet weak var prevArrow: UIImageView!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nextArrow: UIImageView!
    @IBOutlet weak var nextButtonLayout: UIStackView!
    @IBOutlet weak var previousButtonLayout: UIStackView!
    @IBOutlet weak var navigationButtonLayout: UIStackView!
    @IBOutlet weak var bottomShadowView: UIView!
    
    let bottomGradient = CAGradientLayer()
    var pageViewController: UIPageViewController!
    var bookmarksDataSource: BookmarksDetailDataSource!
    var parentviewController: BookmarksSlidingViewController!
    var currentPosition: Int = 0
    var emptyView: EmptyView!
    var activityIndicator: UIActivityIndicatorView! // Progress bar
    var bookmarksTableViewController: BookmarksTableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emptyView = EmptyView.getInstance(parentView: questionsContainerView)
        
        activityIndicator = UIUtils.initActivityIndicator(parentView: questionsContainerView)
        activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y - 50)
        
        pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                  navigationOrientation: .horizontal,
                                                  options: nil)
        
        pageViewController.delegate = self
        addChild(pageViewController)
        questionsContainerView.addSubview(pageViewController.view)
        pageViewController.view.frame = questionsContainerView.bounds
        pageViewController.didMove(toParent: self)
        // Set navigation buttons click listener
        let previousButtonGesture = UITapGestureRecognizer(target: self, action:
            #selector(self.onClickPreviousButton(sender:)))
        previousButtonLayout.addGestureRecognizer(previousButtonGesture)
        let nextButtonGesture = UITapGestureRecognizer(target: self, action:
            #selector(self.onClickNextButton(sender:)))
        nextButtonLayout.addGestureRecognizer(nextButtonGesture)
        // Set navigation buttons text color
        prevButton.setTitleColor(UIColor.lightGray, for: .disabled)
        prevButton.setTitleColor(TestpressCourse.shared.primaryColor, for: .normal)
        nextButton.setTitleColor(UIColor.lightGray, for: .disabled)
        nextButton.setTitleColor(TestpressCourse.shared.primaryColor, for: .normal)
        
        bookmarksTableViewController = parentviewController.tableViewController
    }
    
    func onDataSetChanged(currentPosition: Int) {
        if bookmarksDataSource.bookmarks.isEmpty {
            navigationButtonLayout.isHidden = true
            emptyView.show(
                image:UIImage(named: "bookmark_folder_flat_icon", in: TestpressCourse.bundle, compatibleWith: nil),
                title: Strings.NO_BOOKMARKS,
                description: Strings.NO_BOOKMARKS_DESCRIPTION
            )
            pageViewController.setViewControllers([UIViewController()] , direction: .forward,
                                                  animated: false, completion: nil)
            
            if parentviewController.isRightOpen() {
                parentviewController.onPressBackButton()
            }
            return
        }
        emptyView.hide()
        navigationButtonLayout.isHidden = false
        setCurrentItem(position: currentPosition, dataSetChanged: true)
    }
    
    // MARK: - UIPageViewController delegate methods
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        
        // When user swipe the page, set current question
        if completed {
            updateNavigationButtons(index: getCurrentIndex())
        }
    }
    
    func getCurrentIndex() -> Int {
        if pageViewController.viewControllers!.isEmpty {
            return -1
        }
        return bookmarksDataSource.indexOfViewController(pageViewController.viewControllers![0])
    }
    
    func setCurrentItem(position: Int, dataSetChanged: Bool = false, animated: Bool = true) {
        let currentPosition = getCurrentIndex()
        if  position < 0 || position >= bookmarksDataSource.bookmarks.count ||
            (!dataSetChanged && position == currentPosition) {
            return
        }
        let viewController =
            [bookmarksDataSource.viewControllerAtIndex(position)] as! [UIViewController]
        
        var direction: UIPageViewController.NavigationDirection = .forward
        if currentPosition != -1 {
            direction = position >= currentPosition ? .forward : .reverse
        }
        let animated = !pageViewController.view.isHidden && animated
        
        pageViewController.setViewControllers(viewController , direction: direction,
                                              animated: animated, completion: {done in })
        
        updateNavigationButtons(index: position)
        if parentviewController.isRightOpen() {
            bookmarksTableViewController.setCurrentItem(position: position)
        }
    }
    
    func updateNavigationButtons(index: Int) {
        // Update previous button
        if index == 0 {
            previousButtonLayout.isUserInteractionEnabled = false
            enableButton(prevButton, enable: false)
        } else {
            previousButtonLayout.isUserInteractionEnabled = true
            enableButton(prevButton, enable: true)
        }
        // Update next button
        if (index + 1) == bookmarksDataSource.bookmarks.count {
            if bookmarksTableViewController.pager.hasNext() {
                enableButton(nextButton, enable: true)
            } else {
                enableButton(nextButton, enable: false)
            }
        } else {
            enableButton(nextButton, enable: true)
        }
    }
    
    func enableButton(_ button: UIButton, enable: Bool) {
        if button == prevButton {
            enableButton(button, enable: enable, navigationArrow: prevArrow,
                         buttonLayout: previousButtonLayout)
        } else {
            enableButton(button, enable: enable, navigationArrow: nextArrow,
                         buttonLayout: nextButtonLayout)
        }
    }
    
    func enableButton(_ button: UIButton, enable: Bool, navigationArrow: UIImageView,
                      buttonLayout: UIStackView) {
        
        button.isEnabled = enable
        buttonLayout.isUserInteractionEnabled = enable
        navigationArrow.tintColor = enable ? TestpressCourse.shared.primaryColor : UIColor.lightGray
    }
    
    @objc func onClickPreviousButton(sender: UITapGestureRecognizer) {
        if (getCurrentIndex() + 1) == bookmarksDataSource.bookmarks.count
            && pageViewController.view.isHidden {
            
            pageViewController.view.isHidden = false
            enableButton(nextButton, enable: true)
            enableButton(prevButton, enable: getCurrentIndex() != 0)
            emptyView.hide()
        } else {
            setCurrentItem(position: getCurrentIndex() - 1)
        }
    }
    
    @objc func onClickNextButton(sender: UITapGestureRecognizer) {
        if (getCurrentIndex() + 1) == bookmarksDataSource.bookmarks.count {
            if bookmarksTableViewController.tableView.tableFooterView!.isHidden {
                pageViewController.view.isHidden = true
                showErrorEmptyView(
                    image: UIImage(named: "testpress_no_wifi", in: TestpressCourse.bundle, compatibleWith: nil)!,
                    title: Strings.NETWORK_ERROR,
                    description: Strings.PLEASE_CHECK_INTERNET_CONNECTION
                )
            } else {
                activityIndicator.startAnimating()
                pageViewController.view.isHidden = true
            }
            enableButton(nextButton, enable: false)
            enableButton(prevButton, enable: true)
        } else {
            setCurrentItem(position: getCurrentIndex() + 1)
        }
    }
    
    func showErrorEmptyView(image: UIImage, title: String, description: String) {
        if activityIndicator.isAnimating {
            activityIndicator.stopAnimating()
        }
        let retryHandler = {
            self.emptyView.hide()
            self.activityIndicator.startAnimating()
            self.bookmarksTableViewController.tableView.tableFooterView!.isHidden = false
            self.bookmarksTableViewController.tableViewDelegate.loadItems()
        }
        emptyView.show(image: image, title: title, description: description,
                       retryHandler: retryHandler)
    }
    
    func updateBookmarks(_ bookmarks: [Bookmark]) {
        bookmarksDataSource = BookmarksDetailDataSource(bookmarks)
        pageViewController.dataSource = bookmarksDataSource
        var currentPosition = getCurrentIndex()
        if pageViewController.view.isHidden {
            currentPosition += 1
        } else if currentPosition == -1 {
            currentPosition = 0
        }
        onDataSetChanged(currentPosition: currentPosition)
        if pageViewController.view.isHidden {
            pageViewController.view.isHidden = false
            if activityIndicator.isAnimating {
                activityIndicator.stopAnimating()
            }
        }
    }
    
    func gotoBookmark(position: Int) {
        parentviewController.slideMenuController()?.openRight()
        parentviewController.foldersDropDown.titleButton.isHidden = true
        if pageViewController.view.isHidden {
            pageViewController.view.isHidden = false
            if activityIndicator.isAnimating {
                activityIndicator.stopAnimating()
            } else {
                emptyView.hide()
            }
            if position + 1 == bookmarksDataSource.bookmarks.count {
                updateNavigationButtons(index: position)
            }
        }
        setCurrentItem(position: position, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        // Add gradient shadow layer to the shadow container view
        UIUtils.updateBottomShadow(bottomShadowView: bottomShadowView,
                                   bottomGradient: bottomGradient)
    }
    
}
