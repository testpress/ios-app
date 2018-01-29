//
//  ContentDetailDataSource.swift
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

class ContentDetailDataSource: NSObject, UIPageViewControllerDataSource {
    
    var contents: [Content]!
    var initialPosition: Int!
    var contentAttemptCreationDelegate: ContentAttemptCreationDelegate?
    
    init(_ contents: [Content], _ contentAttemptCreationDelegate: ContentAttemptCreationDelegate?) {
        super.init()
        self.contents = contents
        self.contentAttemptCreationDelegate = contentAttemptCreationDelegate
    }
    
    func viewControllerAtIndex(_ index: Int) -> UIViewController? {
        if (contents.count == 0) || (index >= contents.count) {
            return nil
        }
        
        let content = contents[index]
        content.index = index
        let storyboard = UIStoryboard(name: Constants.CHAPTER_CONTENT_STORYBOARD, bundle: nil)
        
        if content.exam != nil {
            if content.attemptsCount != nil && content.attemptsCount > 0 {
                let viewController = storyboard.instantiateViewController(
                    withIdentifier: Constants.CONTENT_EXAM_ATTEMPS_TABLE_VIEW_CONTROLLER
                    ) as! ContentExamAttemptsTableViewController
                
                viewController.content = content
                return viewController
            } else {
                let viewController = storyboard.instantiateViewController(withIdentifier:
                    Constants.CONTENT_START_EXAM_VIEW_CONTROLLER) as! StartExamScreenViewController
                
                viewController.content = content
                return viewController
            }
        } else if content.attachment != nil {
            let viewController = storyboard.instantiateViewController(withIdentifier:
                Constants.ATTACHMENT_DETAIL_VIEW_CONTROLLER) as! AttachmentDetailViewController
            
            viewController.content = content
            viewController.contentAttemptCreationDelegate = contentAttemptCreationDelegate
            return viewController
        } else {
            let viewController = storyboard.instantiateViewController(withIdentifier:
                Constants.HTML_CONTENT_VIEW_CONTROLLER) as! HtmlContentViewController
        
            viewController.content = content
            viewController.contentAttemptCreationDelegate = contentAttemptCreationDelegate
            return viewController
        }
    }
    
    func indexOfViewController(_ viewController: UIViewController) -> Int {
        if viewController is ContentExamAttemptsTableViewController {
            return (viewController as! ContentExamAttemptsTableViewController).content.index
        } else if viewController is StartExamScreenViewController {
            return (viewController as! StartExamScreenViewController).content.index
        } else if viewController is AttachmentDetailViewController {
            return (viewController as! AttachmentDetailViewController).content.index
        } else {
            return (viewController as! HtmlContentViewController).content.index
        }
    }
    
    // MARK: - Page View Controller Data Source
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore
        viewController: UIViewController) -> UIViewController? {
        
        var index = indexOfViewController(viewController)
        if index == 0 {
            return nil
        }
        index -= 1
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter
        viewController: UIViewController) -> UIViewController? {
        
        var index = indexOfViewController(viewController)
        index += 1
        if index == contents.count {
            return nil
        }
        return viewControllerAtIndex(index)
    }
    
}
