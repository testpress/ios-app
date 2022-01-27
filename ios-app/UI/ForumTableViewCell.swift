//
//  ForumTableViewCell.swift
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

class ForumTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var commentsCount: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var postViewCell: UIView!
    @IBOutlet weak var authorName: UILabel!
    @IBOutlet weak var categoryName: UILabel!
    
    var parentViewController: UIViewController! = nil
    var post: Post!
    
    func initCell(_ post: Post, viewController: UIViewController) {
        parentViewController = viewController
        self.post = post
        userImage.kf.setImage(with: URL(string: post.createdBy.mediumImage!),
                              placeholder: Images.PlaceHolder.image)
        
        postTitle.text = post.title
        authorName.text = post.createdBy.displayName
        categoryName.text = post.category?.name ?? "Uncategorized"
        commentsCount.text = String(post.commentsCount)
        if post.lastCommentedBy == nil {
            displayLastResponder(userName: post.createdBy.displayName, action: " started ",
                                 date: post.publishedDate)
        } else {
            displayLastResponder(userName: post.lastCommentedBy.displayName, action: " replied ",
                                 date: post.lastCommentedTime)
        }
        viewsLabel.text = "\(post.viewsCount!) views"
        
        let tapRecognizer = UITapGestureRecognizer(target: self,
                                                   action: #selector(self.onItemClick))
        
        postViewCell.addGestureRecognizer(tapRecognizer)
    }
    
    func displayLastResponder(userName: String, action: String, date: String) {
        let text = userName + action +  FormatDate.getElapsedTime(dateString: date)
        authorName.text = text
        let attributedString = NSMutableAttributedString(string: text)
        let range = (text as NSString).range(of: action)
        attributedString.addAttribute(
            NSAttributedString.Key.font,
            value: UIFont(name: "Rubik-Regular", size: 12.0)!,
            range: range
        )
        authorName.attributedText = attributedString
    }
    
    @objc func onItemClick() {
        let storyboard = UIStoryboard(name: Constants.POST_STORYBOARD, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier:"DiscussionThreadDetailViewController") as! DiscussionThreadDetailViewController
        
        viewController.post = post
        viewController.forum = true
        parentViewController.present(viewController, animated: true, completion: nil)
    }
    
}
