//
//  PostTableViewCell.swift
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

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var categoryLayout: UIStackView!
    @IBOutlet weak var postViewCell: UIView!
    
    var parentViewController: UIViewController! = nil
    var post: Post!
    
    func initCell(_ post: Post, viewController: UIViewController) {
        parentViewController = viewController
        self.post = post
        postTitle.text = post.title
        date.text = FormatDate.getElapsedTime(dateString: post.publishedDate)
        if post.category != nil {
            category.text = post.category.name
            categoryLayout.isHidden = false
        } else {
            categoryLayout.isHidden = true
        }
        
        let tapRecognizer = UITapGestureRecognizer(target: self,
                                                   action: #selector(self.onItemClick))
        
        postViewCell.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func onItemClick() {
        let storyboard = UIStoryboard(name: Constants.POST_STORYBOARD, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier:
                Constants.POST_DETAIL_VIEW_CONTROLLER) as! PostDetailViewController
        
        viewController.post = post
        parentViewController.present(viewController, animated: true, completion: nil)
    }
    
}
