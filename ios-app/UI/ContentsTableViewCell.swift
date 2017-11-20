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
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var questionsCount: UILabel!
    @IBOutlet weak var examDetailsLayout: UIStackView!
    
    var parentViewController: UIViewController! = nil
    var content: Content!
    
    func initCell(_ content: Content, viewController: UIViewController) {
        parentViewController = viewController
        self.content = content
        contentName.text = content.name
        thumbnailImage.kf.setImage(with: URL(string: content.image!),
                                   placeholder: Images.PlaceHolder.image)
        
        if content.exam != nil {
            duration.text = content.exam?.duration
            questionsCount.text = String(content.exam!.numberOfQuestions!)
            examDetailsLayout.isHidden = false
        } else {
            examDetailsLayout.isHidden = true
        }
        
        let tapRecognizer = UITapGestureRecognizer(target: self,
                                                   action: #selector(self.onItemClick))
        
        contentViewCell.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func onItemClick() {
        // Display content detail
    }
    
}
