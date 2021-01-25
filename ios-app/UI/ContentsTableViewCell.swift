//
//  ContentsTableViewCell.swift
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

class ContentsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var contentName: UILabel!
    @IBOutlet weak var contentViewCell: UIView!
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var videoDurationLabel: UILabel!
    @IBOutlet weak var thumbnailImageContainer: UIView!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var questionsCount: UILabel!
    @IBOutlet weak var examDetailsLayout: UIStackView!
    @IBOutlet weak var attemptedTick: UIImageView!
    @IBOutlet weak var lock: UIView!
    @IBOutlet weak var contentLayout: UIStackView!
    @IBOutlet weak var questionsCountStack: UIStackView!
    
    var parentViewController: ContentsTableViewController! = nil
    var position: Int!
    
    func initCell(position: Int, viewController: ContentsTableViewController) {
        parentViewController = viewController
        self.position = position
        let content = parentViewController.items[position]
        contentName.text = content.name
        thumbnailImage.addRoundedCorners(radius: 3.0)
        lock.addRoundedCorners(radius: 9.0)
        addThumbnail(content: content)

        if content.exam != nil {
            duration.text = content.exam?.duration
            questionsCount.text = String(content.exam!.numberOfQuestions)
            examDetailsLayout.isHidden = false

        } else if content.video != nil {
            thumbnailImageContainer.addSubview(videoDurationLabel)
            videoDurationLabel.addRoundedCorners(radius: 2.0)
            videoDurationLabel.isHidden = false
            videoDurationLabel.text = content.video?.duration
            examDetailsLayout.isHidden = true
        } else {
            examDetailsLayout.isHidden = true
        }
        if content.isLocked || content.isScheduled{
            lock.isHidden = false
            contentLayout.alpha = 0.5
            thumbnailImage.alpha = 0.5
            attemptedTick.isHidden = true
            
            if (content.isScheduled) {
                showScheduledDate()
            }

        } else {
            lock.isHidden = true
            contentLayout.alpha = 1
            thumbnailImage.alpha = 1
            attemptedTick.isHidden = content.attemptsCount == 0
        }
        thumbnailImageContainer.addSubview(attemptedTick)
        let tapRecognizer = UITapGestureRecognizer(target: self,
                                                   action: #selector(self.onItemClick))
        
        contentViewCell.addGestureRecognizer(tapRecognizer)
    }
    
    func addThumbnail(content: Content) {
        if (content.coverImageSmall != nil) {
            thumbnailImage.isHidden = false
            thumbnailImage.contentMode = .scaleToFill
            thumbnailImage.kf.setImage(with: URL(string: content.coverImageSmall),
                                       placeholder: Images.PlaceHolder.image)
        } else {
            thumbnailImageContainer.backgroundColor = UIColor.lightGray
            thumbnailImage.isHidden = true

            let frontimgview = UIImageView(image: getThumbnailIcon(content: content))
            frontimgview.frame = CGRect(x: (thumbnailImageContainer.frame.width / 2) - 13, y: (thumbnailImageContainer.frame.height / 2) - 13, width: 32, height: 32)
            thumbnailImageContainer.addSubview(frontimgview)
        }
    }
    
    func getThumbnailIcon(content: Content) -> UIImage {
        if (content.video != nil) {
            return Images.VideoIconWhite.image
        } else if (content.videoConference != nil) {
            return Images.LiveClassIcon.image
        } else if (content.htmlObject != nil) {
            return Images.NotesIconWhite.image
        } else if (content.attachment != nil) {
            return Images.AttachmentIconWhite.image
        }
        return Images.ExamIconWhite.image
    }
    
    func showScheduledDate() {
        let content = parentViewController.items[position]

        if content.isScheduled {
            examDetailsLayout.isHidden = false
            let date = FormatDate.format(dateString: content.start)
            duration.text = "This will be available on \(date)"
            questionsCountStack.isHidden = true
        }
    }
    
    func addOverlay(on view: UIView) {
        let overlay: UIView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        overlay.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.1)
        view.addSubview(overlay)
    }
    
    @objc func onItemClick() {
        let content = parentViewController.items[position]
        
        if (content.isScheduled) {
            return
        }
        
        let viewController = parentViewController.storyboard?.instantiateViewController(
            withIdentifier: Constants.CONTENT_DETAIL_PAGE_VIEW_CONTROLLER)
            as! ContentDetailPageViewController
        
        viewController.contents = parentViewController.items
        viewController.title = parentViewController.title
        viewController.contentAttemptCreationDelegate = parentViewController
        viewController.position = position
        parentViewController.present(viewController, animated: true, completion: nil)
    }
    
}


extension UIView {
    func addRoundedCorners(radius: Float) {
        layer.cornerRadius = 3.0
        self.clipsToBounds = true
    }
}
