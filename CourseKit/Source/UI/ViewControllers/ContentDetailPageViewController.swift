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

public class ContentDetailPageViewController: BaseUIViewController, UIPageViewControllerDelegate {
    
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
    public var contents = [Content]()
    public var position: Int!
    var emptyView: EmptyView!
    var activityIndicator: UIActivityIndicatorView!
    var url: String? = nil
    public var contentId: Int?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setStatusBarColor()
        setupPageViewController()
        setupNavigationButtons()
        setupActivityIndicator()
        setupEmptyView()
        setupContentDetailDataSource()
        setupInitialView()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if contents.isEmpty && contentId != nil {
            loadContent()
        } else if pageViewController.viewControllers?.count == 0 {
            setFirstViewController()
        }

        enableBookmarkOption()
    }
    
    public override func viewDidLayoutSubviews() {
        // Add gradient shadow layer to the shadow container view
        UIUtils.updateBottomShadow(bottomShadowView: bottomShadowView,
                                   bottomGradient: bottomGradient)
        emptyView.frame = contentsContainerView.bounds
        
    }
    
    private func setupPageViewController() {
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.delegate = self
        addChild(pageViewController)
        contentsContainerView.addSubview(pageViewController.view)
        pageViewController.view.frame = contentsContainerView.bounds
        pageViewController.didMove(toParent: self)
        disableSwipeGesture()
    }
    
    private func setupNavigationButtons() {
        addTapGesture(to: previousButtonLayout, action: #selector(onClickPreviousButton))
        addTapGesture(to: nextButtonLayout, action: #selector(onClickNextButton))
        setButtonColors(button: prevButton, isEnabled: true)
        setButtonColors(button: nextButton, isEnabled: true)
    }
    
    private func setupEmptyView(){
        emptyView = EmptyView.getInstance(parentView: pageViewController.view)
    }
    
    private func setupContentDetailDataSource(){
        contentDetailDataSource = ContentDetailDataSource(contents, contentAttemptCreationDelegate)
    }
    
    private func setupActivityIndicator() {
        activityIndicator = UIUtils.initActivityIndicator(parentView: pageViewController.view)
        activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y - 50)
    }
    
    private func setupInitialView() {
        navigationBarItem.title = title
        if contents.count < 2 {
            hideBottomNavBar()
        }
    }

    private func setButtonColors(button: UIButton, isEnabled: Bool) {
        let color = isEnabled ? TestpressCourse.shared.primaryColor : UIColor.lightGray
        button.setTitleColor(color, for: isEnabled ? .normal : .disabled)
    }
    
    private func addTapGesture(to view: UIView, action: Selector) {
        let gesture = UITapGestureRecognizer(target: self, action: action)
        view.addGestureRecognizer(gesture)
    }
    
    private func updateNavigationButtons(index: Int) {
        previousButtonLayout.isUserInteractionEnabled = (index > 0)
        prevButton.isEnabled = (index > 0)
        prevArrow.tintColor = (index > 0) ? TestpressCourse.shared.primaryColor : UIColor.lightGray
        
        let isLastPage = (index + 1 == contentDetailDataSource?.contents.count)
        nextButton.isEnabled = !isLastPage
        nextArrow.tintColor = isLastPage ? UIColor.lightGray : TestpressCourse.shared.primaryColor
    }
    
    // MARK: - Page View Controller Methods
    private func setFirstViewController() {
        if let startingViewController = contentDetailDataSource.viewControllerAtIndex(position) {
            pageViewController.setViewControllers([startingViewController], direction: .forward, animated: false)
            pageViewController.dataSource = contentDetailDataSource
            updateNavigationButtons(index: getCurrentIndex())
        }
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
    
    // MARK: - UIPageViewController delegate methods
    
    public func pageViewController(_ pageViewController: UIPageViewController,
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
    
    
    func loadContent() {
        guard let contentId = contentId else { return }
        activityIndicator.startAnimating()
        
        let url = TestpressCourse.shared.baseURL + "/api/v2.4/contents/\(contentId)/"
        TPApiClient.request(
            type: Content.self,
            endpointProvider: TPEndpointProvider(.get, url: url),
            completion: { [weak self] content, error in
                self?.activityIndicator.stopAnimating()
                guard let content = content else {
                    self?.displayContentLoadingError(error)
                    return
                }
                
                self?.contents = [content]
                self?.position = 0
                self?.setupContentDetailDataSource()
                self?.setFirstViewController()
                self?.navigationBarItem.title = content.name
            }
        )
    }
    
    
    func updateContent() {
        activityIndicator.startAnimating()
        let content = contents[getCurrentIndex()]
        
        TPApiClient.request(
            type: Content.self,
            endpointProvider: TPEndpointProvider(.get, url: content.getUrl()),
            completion: {content, error in
                self.activityIndicator.stopAnimating()

                guard let content = content else {
                    self.displayContentLoadingError(error)
                    return
                }

                self.updateContentData(content)
            }
        )
    }

    private func displayContentLoadingError(_ error: TPError?) {
        guard let error = error else { return }
        
        debugPrint(error.message ?? "No error")
        debugPrint(error.kind)
        
        var retryHandler: (() -> Void)?
        if error.kind == .network {
            retryHandler = { [weak self] in
                self?.emptyView.hide()
                self?.updateContent()
            }
        }
        
        let (image, title, description) = error.getDisplayInfo()
        emptyView.show(
            image: image,
            title: title,
            description: description,
            retryHandler: retryHandler
        )
    }

    private func updateContentData(_ content: Content) {
        contents[getCurrentIndex()] = content
        contentDetailDataSource.contents = contents
        
        guard let viewController = contentDetailDataSource.viewControllerAtIndex(getCurrentIndex()) else {
            return
        }
        
        pageViewController.setViewControllers(
            [viewController],
            direction: .forward,
            animated: true,
            completion: nil
        )
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
}

extension ContentDetailPageViewController: TestEngineNavigationDelegate{
    public func navigateBack() {
        dismiss(animated: false) {
            self.updateCurrentExamContent()
        }
    }
}
