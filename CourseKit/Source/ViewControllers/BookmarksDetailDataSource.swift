//
//  BookmarksDetailDataSource.swift
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
import CourseKit

class BookmarksDetailDataSource: NSObject, UIPageViewControllerDataSource {
    
    var bookmarks = [Bookmark]()
    
    init(_ bookmarks: [Bookmark]) {
        self.bookmarks = bookmarks
        super.init()
    }
    
    func viewControllerAtIndex(_ index: Int) -> UIViewController? {
        if (bookmarks.count == 0) || (index >= bookmarks.count) {
            return nil
        }
        
        let bookmark = bookmarks[index]
        if let attemptItem = bookmark.bookmarkedObject as? AttemptItem {
            let storyboard = UIStoryboard(name: Constants.BOOKMARKS_STORYBOARD, bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier:
                 Constants.BOOKMARKED_QUESTION_VIEW_CONTROLLER) as! BookmarkedQuestionViewController
            
            viewController.attemptItem = attemptItem
            viewController.bookmark = bookmark
            viewController.position = index
            return viewController
        } else if let content = bookmark.bookmarkedObject as? Content {
            content.attemptsUrl = Constants.BASE_URL + TPEndpoint.getContents.urlPath
                + "\(content.id)" + TPEndpoint.attemptsPath.urlPath
            
            if content.attachment != nil {
                let storyboard =
                    UIStoryboard(name: Constants.CHAPTER_CONTENT_STORYBOARD, bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier:
                    Constants.ATTACHMENT_DETAIL_VIEW_CONTROLLER) as! AttachmentDetailViewController
                
                viewController.content = content
                viewController.bookmark = bookmark
                viewController.position = index
                return viewController
            } else if content.video != nil {
                let storyboard =
                    UIStoryboard(name: Constants.CHAPTER_CONTENT_STORYBOARD, bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier:
                    Constants.VIDEO_CONTENT_VIEW_CONTROLLER) as! VideoContentViewController
                
                viewController.content = content
                viewController.contents = [content]
                viewController.position = index
                return viewController
            } else {
                let viewController = BookmarkedHtmlContentViewController()
                viewController.content = content
                viewController.bookmark = bookmark
                viewController.position = index
                return viewController
            }
            
        } 
        return UIViewController()
    }
        
    func indexOfViewController(_ viewController: UIViewController) -> Int {
        if viewController is BookmarkedQuestionViewController {
            return (viewController as! BookmarkedQuestionViewController).position
        } else if viewController is AttachmentDetailViewController {
            return (viewController as! AttachmentDetailViewController).position
        } else if viewController is BookmarkedHtmlContentViewController {
            return (viewController as! BookmarkedHtmlContentViewController).position
        } else if (viewController is VideoContentViewController) {
            return (viewController as! VideoContentViewController).position
        }
        return -1
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
        
        if index == bookmarks.count {
            return nil
        }
        return viewControllerAtIndex(index)
    }
    
}
