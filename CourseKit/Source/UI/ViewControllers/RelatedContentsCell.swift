//
//  RelatedContentsCell.swift
//  ios-app
//
//  Created by Karthik raja on 12/8/19.
//  Copyright © 2019 Testpress. All rights reserved.
//

import UIKit

class RelatedContentsCell: UITableViewCell {
    
    @IBOutlet weak var contentIcon: UIImageView!
    @IBOutlet weak var bookmarkIcon: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var desc: UILabel!
    var content: Content?
    var index: Int?
    var contents: [Content]?
    var parentViewController: UIViewController? = nil
    var isAlreadySelected: Bool = false
    
    func initCell(index: Int, contents: [Content], viewController: UIViewController, is_current: Bool=false) {
        parentViewController = viewController
        content = contents[index]
        self.contents = contents
        self.index = index
        title.text = content?.name
        bookmarkIcon.isHidden = false
        isAlreadySelected = false
        
        if content?.exam != nil {
            contentIcon.image = Images.Quill.image
            bookmarkIcon.isHidden = true
        } else if content?.htmlContentTitle != nil {
            contentIcon.image = Images.Article.image
        } else if content?.video != nil {
            contentIcon.image = Images.VideoIcon.image
        } else if content?.attachment != nil {
            contentIcon.image = Images.Attachment.image
        }
        
        if content?.bookmarkId != nil {
            bookmarkIcon.image = Images.RemoveBookmark.image
        } else {
            bookmarkIcon.image = Images.AddBookmark.image
        }
        
        contentIcon.setImageColor(color: Colors.getRGB(Colors.DIM_GRAY))
        bookmarkIcon.setImageColor(color: Colors.getRGB(Colors.DIM_GRAY))
        self.backgroundColor = Colors.getRGB(Colors.WHITE)
        title.textColor = Colors.getRGB(Colors.DIM_GRAY)
        desc.textColor = Colors.getRGB(Colors.DIM_GRAY)
        desc.isHidden = true
        
        if (is_current) {
            isAlreadySelected = true
            contentIcon.setImageColor(color: TestpressCourse.shared.primaryColor)
            bookmarkIcon.setImageColor(color: TestpressCourse.shared.primaryColor)
            self.backgroundColor = TestpressCourse.shared.primaryColor.withAlphaComponent(0.1)
            title.textColor = TestpressCourse.shared.primaryColor
            desc.textColor = TestpressCourse.shared.primaryColor
            
            if (content?.video != nil) {
                desc.text = "Now Playing..."
                desc.isHidden = false
            }
        }
        
        let tapRecognizer = UITapGestureRecognizer(target: self,
                                                   action: #selector(self.onItemClick))
        
        addGestureRecognizer(tapRecognizer)
        
        bookmarkIcon.addTapGestureRecognizer{
            if let viewController = self.parentViewController as? VideoContentViewController {
                viewController.addOrRemoveBookmark(content: self.content)
            }
        }
        
    }
    
    @objc func onItemClick() {
        if isAlreadySelected {
            return
        }
        
        if (content?.video != nil && content!.video!.embedCode.isEmpty) {
            if let viewController = self.parentViewController as? VideoContentViewController {
                viewController.updateVideoAttempt()
                viewController.changeVideo(content: content)
                return
            }
        }
        
        let storyboard = UIStoryboard(name: Constants.CHAPTER_CONTENT_STORYBOARD, bundle: TestpressCourse.bundle)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: Constants.CONTENT_DETAIL_PAGE_VIEW_CONTROLLER)
            as! ContentDetailPageViewController
        
        viewController.contents = contents!
        viewController.title = content?.name
        viewController.position = index
        parentViewController?.present(viewController, animated: false, completion: nil)
        
    }
}


extension UIImageView {
    func setImageColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
    
}
