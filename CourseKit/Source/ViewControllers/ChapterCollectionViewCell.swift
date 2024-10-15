//
//  ChapterCollectionViewCell.swift
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

class ChapterCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var chapterName: UILabel!
    @IBOutlet weak var chapterViewCell: UIView!
    @IBOutlet weak var thumbnailImage: UIImageView!
    
    var parentViewController: UIViewController! = nil
    var chapter: Chapter!
    
    func initCell(_ chapter: Chapter, viewController: UIViewController) {
        parentViewController = viewController
        self.chapter = chapter
        chapterName.text = chapter.name
        thumbnailImage.kf.setImage(with: URL(string: chapter.image),
                                   placeholder: Images.PlaceHolder.image)
        
        let tapRecognizer = UITapGestureRecognizer(target: self,
                                                   action: #selector(self.onItemClick))
        
        chapterViewCell.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func onItemClick() {
        let storyboard = UIStoryboard(name: Constants.CHAPTER_CONTENT_STORYBOARD, bundle: bundle)
        var viewController: UIViewController
        if !chapter.leaf {
            let chapterViewController = storyboard.instantiateViewController(withIdentifier:
                Constants.CHAPTERS_VIEW_CONTROLLER) as! ChaptersViewController
            chapterViewController.courseId = chapter.courseId
            chapterViewController.coursesUrl = chapter.url
            chapterViewController.parentId = chapter.id
            chapterViewController.title = chapter.name
            viewController = chapterViewController
        } else {
            let contentsNavigationController = storyboard.instantiateViewController(withIdentifier:
                Constants.CONTENTS_LIST_NAVIGATION_CONTROLLER) as! UINavigationController
            
            let contentViewController = contentsNavigationController.viewControllers.first
                as! ContentsTableViewController
            
            contentViewController.contentsUrl = chapter.getContentsUrl()
            contentViewController.title = chapter.name
            contentViewController.chapterId = chapter.id
            viewController = contentsNavigationController
        }
        parentViewController.present(viewController, animated: true, completion: nil)
    }
}
