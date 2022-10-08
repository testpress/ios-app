//
//  ContentDetailPageViewController.swift
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

class ContentDetailPageViewController: UIViewController, UIPageViewControllerDelegate {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var contentsContainerView: UIView!
    @IBOutlet weak var prevArrow: UIImageView!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nextArrow: UIImageView!
    @IBOutlet weak var nextButtonLayout: UIStackView!
    @IBOutlet weak var previousButtonLayout: UIStackView!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    @IBOutlet weak var bottomShadowView: UIView!
    @IBOutlet weak var bottomNavigationBar: UIStackView!
    @IBOutlet weak var bottomNavigationBarConstraint: NSLayoutConstraint!
    @IBOutlet weak var bookmarkButton: UIBarButtonItem!
    
    let bottomGradient = CAGradientLayer()
    var pageViewController: UIPageViewController!
    var contentDetailDataSource: ContentDetailDataSource!
    var contentAttemptCreationDelegate: ContentAttemptCreationDelegate? = nil
    var currentIndex: Int!
    var contents = [Content]()
    var position: Int!
    var emptyView: EmptyView!
    var activityIndicator: UIActivityIndicatorView!
    var url: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStatusBarColor()

        
        pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        pageViewController.delegate = self
        addChild(pageViewController)
        contentsContainerView.addSubview(pageViewController.view)
        pageViewController.view.frame = contentsContainerView.bounds
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
        prevButton.setTitleColor(Colors.getRGB(Colors.PRIMARY), for: .normal)
        nextButton.setTitleColor(UIColor.lightGray, for: .disabled)
        nextButton.setTitleColor(Colors.getRGB(Colors.PRIMARY), for: .normal)
        
        emptyView = EmptyView.getInstance(parentView: pageViewController.view)
        activityIndicator = UIUtils.initActivityIndicator(parentView: pageViewController.view)
        activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y - 50)
        contentDetailDataSource = ContentDetailDataSource(contents, contentAttemptCreationDelegate)
        navigationBarItem.title = title
        if contents.count < 2 {
            hideBottomNavBar()
        }
        disableSwipeGesture()
    }
    
    func hideNavbarTitle() {
        navigationBarItem.title = ""
    }
    
    func hideBottomNavBar() {
        bottomShadowView.isHidden = true
        bottomNavigationBar.isHidden = true
    }
    
    func showBottomNavbar() {
        bottomShadowView.isHidden = false
        bottomNavigationBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if pageViewController.viewControllers?.count == 0 {
            if self.presentingViewController is MainMenuTabViewController {
                loadContent()
            } else {
                setFirstViewController()
                if (contents[getCurrentIndex()].examId != -1) {
                    self.loadContent()
                }
            }
        }

        enableBookmarkOption()
    }
    
    func enableBookmarkOption() {
        if !(pageViewController.viewControllers?.isEmpty)! {
            if getCurrentIndex() != -1 && contentDetailDataSource.viewControllerAtIndex(getCurrentIndex())! is VideoContentViewController {
                navigationBarItem.rightBarButtonItems = [bookmarkButton]
                bookmarkButton.isEnabled = true
                bookmarkButton.image = Images.AddBookmark.image
                if contents[getCurrentIndex()].bookmarkId.value != nil {
                    bookmarkButton.image = Images.RemoveBookmark.image
                }
            } else {
                bookmarkButton.isEnabled = false
                bookmarkButton.image = nil
            }
        }
    }
    
    func setFirstViewController() {
        let startingViewController = contentDetailDataSource.viewControllerAtIndex(position)!
        pageViewController.setViewControllers(
            [startingViewController],
            direction: .forward,
            animated: false
        )
        pageViewController.dataSource = contentDetailDataSource
        updateNavigationButtons(index: getCurrentIndex())
    }
    
    // MARK: - UIPageViewController delegate methods
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        
        // When user swipe the page, set current content
        if completed {
            let currentIndex = getCurrentIndex()
            updateNavigationButtons(index: currentIndex)
        }
    }
    
    func getCurretViewController() -> UIViewController {
        return pageViewController.viewControllers![0]
    }
    
    func getCurrentIndex() -> Int {
        return contentDetailDataSource.indexOfViewController(getCurretViewController())
    }
    
    func setCurrentContent(index: Int) {
        let currentIndex: Int = getCurrentIndex()
        if  index < 0 || index >= contentDetailDataSource.contents.count || index == currentIndex {
            return
        }
        
        let viewController = contentDetailDataSource.viewControllerAtIndex(index)!
        let direction: UIPageViewController.NavigationDirection =
            index > currentIndex ? .forward : .reverse
        
        pageViewController.setViewControllers([viewController] , direction: direction,
                                              animated: true, completion: {done in })
        
        updateNavigationButtons(index: index)
    }
    
    func updateNavigationButtons(index: Int) {
        // Update previous button
        if index == 0 {
            previousButtonLayout.isUserInteractionEnabled = false
            prevButton.isEnabled = false
            prevArrow.tintColor = UIColor.lightGray
        } else {
            previousButtonLayout.isUserInteractionEnabled = true
            prevButton.isEnabled = true
            prevArrow.tintColor = Colors.getRGB(Colors.PRIMARY)
        }
        // Update next button
        if index + 1 == contentDetailDataSource?.contents.count {
            nextButton.isEnabled = false
            nextArrow.tintColor = UIColor.lightGray
        } else {
            nextButton.isEnabled = true
            nextArrow.tintColor = Colors.getRGB(Colors.PRIMARY)
        }
    }
    
    @objc func onClickPreviousButton(sender: UITapGestureRecognizer) {
        setCurrentContent(index: getCurrentIndex() - 1)
    }
    
    @objc func onClickNextButton(sender: UITapGestureRecognizer) {
        setCurrentContent(index: getCurrentIndex() + 1)
    }
    
    func updateCurrentExamContent() {
        if let viewController =
            getCurretViewController() as? ContentExamAttemptsTableViewController {

            viewController.attempts.removeAll()
            let content = viewController.content!
            viewController.loadAttemptsWithProgress(url: content.getAttemptsUrl())
        } else {
            contentAttemptCreationDelegate?.newAttemptCreated()
            updateContent()
        }
    }
    
    func enableSwipeGesture() {
        pageViewController.dataSource = contentDetailDataSource
    }
    
    func disableSwipeGesture() {
        pageViewController.dataSource = nil
        for view in self.pageViewController!.view.subviews {
            if let subView = view as? UIScrollView {
                subView.bounces = false
            }
        }
    }
    
    func updateContent() {
        activityIndicator.startAnimating()
        let content = contents[getCurrentIndex()]
        TPApiClient.request(
            type: Content.self,
            endpointProvider: TPEndpointProvider(.get, url: content.getUrl()),
            completion: {
                content, error in
                if let error = error {
                    debugPrint(error.message ?? "No error")
                    debugPrint(error.kind)
                    var retryHandler: (() -> Void)?
                    if error.kind == .network {
                        retryHandler = {
                            self.emptyView.hide()
                            self.updateContent()
                        }
                    }
                    self.activityIndicator.stopAnimating()
                    let (image, title, description) = error.getDisplayInfo()
                    self.emptyView.show(image: image, title: title, description: description,
                                        retryHandler: retryHandler)
                    
                    return
                }
                
                self.contents[self.getCurrentIndex()] = content!
                self.contentDetailDataSource.contents = self.contents
                let viewController =
                    self.contentDetailDataSource.viewControllerAtIndex(self.getCurrentIndex())
                
                self.pageViewController.setViewControllers([viewController!] , direction: .forward,
                                                           animated: true, completion: {done in })
                
                self.activityIndicator.stopAnimating()
        })
    }
    
    func loadContent() {
        activityIndicator.startAnimating()
        let content = contents[position]
        TPApiClient.request(
            type: Content.self,
            endpointProvider: TPEndpointProvider(.get, url: content.url),
            completion: {
                content, error in
                if let error = error {
                    debugPrint(error.message ?? "No error")
                    debugPrint(error.kind)
                    var retryHandler: (() -> Void)?
                    if error.kind == .network {
                        retryHandler = {
                            self.emptyView.hide()
                            self.updateContent()
                        }
                    }
                    self.activityIndicator.stopAnimating()
                    let (image, title, description) = error.getDisplayInfo()
                    self.emptyView.show(image: image, title: title, description: description,
                                        retryHandler: retryHandler)
                    
                    return
                }
                self.contents[self.position] = content!
                self.contentDetailDataSource.contents = self.contents
                self.setFirstViewController()
                self.activityIndicator.stopAnimating()
        })
    }
    
    @IBAction func back() {
        if let navigationViewController = self.view.window?.rootViewController?.presentedViewController?.presentedViewController as? UINavigationController {
            navigationViewController.dismiss(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    @IBAction func bookMark(_ sender: UIBarButtonItem) {
        if let viewController = self.getCurretViewController() as? VideoContentViewController {
            viewController.addOrRemoveBookmark(content: nil)
        }
    }
    
    override func viewDidLayoutSubviews() {
        // Add gradient shadow layer to the shadow container view
        UIUtils.updateBottomShadow(bottomShadowView: bottomShadowView,
                                   bottomGradient: bottomGradient)
        emptyView.frame = contentsContainerView.bounds
        
    }
    
}
