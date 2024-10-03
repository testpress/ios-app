//
//  BaseQuestionsDataSource.swift
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

class BaseQuestionsDataSource: NSObject, UIPageViewControllerDataSource {
    
    var attemptItems = [AttemptItem]()
    var language: Language?
    
    init(_ attemptItems: [AttemptItem] = [AttemptItem](),_ language: Language? = nil) {
        super.init()
        self.attemptItems = attemptItems
        self.language = language
    }
    
    func setLanguage(_ language: Language) {
        self.language = language
    }
    
    func viewControllerAtIndex(_ index: Int) -> BaseQuestionsViewController? {
        if (attemptItems.count == 0) || (index >= attemptItems.count) {
            return nil
        }
        
        let attemptItem = attemptItems[index]
        DBManager<AttemptItem>().write {
            attemptItem.index = index
        }
        let viewController = getQuestionsViewController()
        viewController.attemptItem = attemptItem
        viewController.language = self.language
        return viewController
    }
    
    func getQuestionsViewController() -> BaseQuestionsViewController {
        return BaseQuestionsViewController()
    }
    
    func indexOfViewController(_ viewController: BaseQuestionsViewController) -> Int {
        return viewController.attemptItem!.index
    }
    
    // MARK: - Page View Controller Data Source
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore
            viewController: UIViewController) -> UIViewController? {
        
        var index = indexOfViewController(viewController as! BaseQuestionsViewController)
        if index == 0 {
            return nil
        }
        
        index -= 1
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter
            viewController: UIViewController) -> UIViewController? {
        
        var index = indexOfViewController(viewController as! BaseQuestionsViewController)
        index += 1
        
        if index == attemptItems.count {
            return nil
        }
        return viewControllerAtIndex(index)
    }
    
}
