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
    
    @IBOutlet weak var contentsContainerView: UIView!
    @IBOutlet weak var prevArrow: UIImageView!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nextArrow: UIImageView!
    @IBOutlet weak var nextButtonLayout: UIStackView!
    @IBOutlet weak var previousButtonLayout: UIStackView!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    
    var pageViewController: UIPageViewController!
    var contentDetailDataSource: ContentDetailDataSource!
    var currentIndex: Int!
    var exam: Exam!
    var contents = [Content]()
    var position: Int!
    var showingProgress: Bool = false
    let loadingDialogController = UIUtils.initProgressDialog(message:
        Strings.LOADING_QUESTIONS + "\n\n")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        pageViewController.delegate = self
        addChildViewController(pageViewController)
        contentsContainerView.addSubview(pageViewController.view)
        pageViewController.view.frame = contentsContainerView.bounds
        pageViewController.didMove(toParentViewController: self)
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
        contentDetailDataSource = ContentDetailDataSource(contents)
        navigationBarItem.title = title
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
    
    func getCurrentIndex() -> Int {
        return contentDetailDataSource.indexOfViewController(pageViewController.viewControllers![0])
    }
    
    func setCurrentContent(index: Int) {
        let currentIndex: Int = getCurrentIndex()
        if  index < 0 || index >= contentDetailDataSource.contents.count || index == currentIndex {
            return
        }
        
        let viewController = contentDetailDataSource.viewControllerAtIndex(index)!
        let direction: UIPageViewControllerNavigationDirection =
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
    
    @IBAction func back() {
        dismiss(animated: true, completion: nil)
    }
    
}
