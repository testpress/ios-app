//
//  CourseTableViewCell.swift
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

class CourseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var courseName: UILabel!
    @IBOutlet weak var courseViewCell: UIView!
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var externalLinkLabel: UILabel!
    
    var parentViewController: UIViewController! = nil
    var course: Course!
    var customCourse: CustomCourse!
    
    func initCell(_ position: Int, viewController: CoursesTableViewController) {
        parentViewController = viewController
        let coursesCount = viewController.items.count
        externalLinkLabel.isHidden = true
        
        if coursesCount > position {
            course = viewController.items[position]
            courseName.text = course.title
            thumbnailImage.kf.setImage(with: URL(string: course.image),
                                       placeholder: Images.PlaceHolder.image)
            if !course.external_content_link.isEmpty {
                displayExternalLabel()
            }
        } else {
            course = nil
            customCourse = viewController.customItems[position - coursesCount]
            courseName.text = customCourse.title
            thumbnailImage.image = customCourse.image
        }
        
        let tapRecognizer = UITapGestureRecognizer(target: self,
                                                   action: #selector(self.onItemClick))
        
        courseViewCell.addGestureRecognizer(tapRecognizer)
        
    }

    
    func displayExternalLabel() {
        externalLinkLabel.text = course.external_link_label
        externalLinkLabel.sizeToFit()
        externalLinkLabel.frame.size.width = externalLinkLabel.intrinsicContentSize.width + 10
        externalLinkLabel.frame.size.height = externalLinkLabel.intrinsicContentSize.height + 10
        externalLinkLabel.textAlignment = .center
        externalLinkLabel.isHidden = false
        externalLinkLabel.layer.borderWidth = 1.0
        externalLinkLabel.layer.cornerRadius = 2
        externalLinkLabel.layer.borderColor = Colors.getRGB(Colors.PRIMARY).cgColor
        externalLinkLabel.textColor = Colors.getRGB(Colors.PRIMARY)
    }
    
    override func layoutSubviews() {
        /*
         In case of device rotation, external link label should be redrawn.
         */
        super.layoutSubviews()
        if course != nil && !course.external_content_link.isEmpty {
            displayExternalLabel()
        }
    }
    
    @objc func onItemClick() {
        let storyboard = UIStoryboard(name: Constants.CHAPTER_CONTENT_STORYBOARD, bundle: nil)
        let viewController: UIViewController
        if !course.external_content_link.isEmpty {
            let webViewController = WebViewController()
            webViewController.url = course.external_content_link
            webViewController.title = course.title
            parentViewController.present(webViewController, animated: true, completion: nil)
        } else {
            if course.chaptersCount > 0 {
                let chaptersViewController = storyboard.instantiateViewController(withIdentifier:
                    Constants.CHAPTERS_VIEW_CONTROLLER) as! ChaptersViewController
                
                chaptersViewController.courseId = course.id
                chaptersViewController.coursesUrl = course.url
                chaptersViewController.title = course.title
                viewController = chaptersViewController
            } else {
                if course.chaptersCount > 0 {
                    let chaptersViewController = storyboard.instantiateViewController(withIdentifier:
                        Constants.CHAPTERS_VIEW_CONTROLLER) as! ChaptersViewController
                    
                    chaptersViewController.coursesUrl = course.url
                    chaptersViewController.title = course.title
                    viewController = chaptersViewController
                } else {
                    let contentsNavigationController = storyboard.instantiateViewController(withIdentifier:
                        Constants.CONTENTS_LIST_NAVIGATION_CONTROLLER) as! UINavigationController
                    
                    let contentViewController = contentsNavigationController.viewControllers.first
                        as! ContentsTableViewController
                    
                    contentViewController.contentsUrl = course.contentsUrl
                    contentViewController.title = course.title
                    viewController = contentsNavigationController
                }
                parentViewController.present(viewController, animated: true, completion: nil)
        }
        }else {
            let storyboard = UIStoryboard(name: Constants.MAIN_STORYBOARD, bundle: nil)
            let browserViewController = storyboard.instantiateViewController(withIdentifier:
                Constants.IN_APP_BROWSER_VIEW_CONTROLLER) as! InAppBrowserViewController
            
            browserViewController.url = customCourse.url
            browserViewController.title = customCourse.title
            viewController = browserViewController
            parentViewController.present(viewController, animated: true, completion: nil)
        }
    
    }
    
}
