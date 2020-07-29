//
//  BookmarksTableViewCell.swift
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

class BookmarksTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var contentName: UILabel!
    @IBOutlet weak var contentViewCell: UIView!
    @IBOutlet weak var thumbnailImageLayout: UIView!
    @IBOutlet weak var thumbnailImage: UIImageView!
    
    var parentViewController: BookmarksTableViewController! = nil
    var position: Int!
    
    func initCell(position: Int, viewController: BookmarksTableViewController) {
        parentViewController = viewController
        self.position = position
        let bookmark = parentViewController.items[position]
        
        if let reviewItem = bookmark.bookmarkedObject as? AttemptItem {
            contentName.text = reviewItem.question.questionHtml?.htmlToString
            thumbnailImage.image = #imageLiteral(resourceName: "question_content_icon")
        } else if let content = bookmark.bookmarkedObject as? Content {
            if content.video != nil {
                contentName.text = content.video!.title
                thumbnailImage.image = #imageLiteral(resourceName: "video_added_icon")
            } else if content.attachment != nil {
                contentName.text = content.attachment!.title
                thumbnailImage.image = #imageLiteral(resourceName: "file_download_icon")
            } else if content.htmlObject != nil {
                contentName.text = content.htmlObject?.title
                thumbnailImage.image = #imageLiteral(resourceName: "ebook_content_icon")
            }
        }
        
        setSelectionBackgroundColor(hex: Colors.GRAY_LIGHT_DARK)
    }
    
    override func updateSubViewsBackgroundColor() {
        thumbnailImageLayout.backgroundColor = Colors.getRGB(Colors.BLUE_TEXT, alpha: 0.1)
    }
    
}
