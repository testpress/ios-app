//
//  EmptyView.swift
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

class EmptyView: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var emptyViewTitle: UILabel!
    @IBOutlet weak var emptyViewDescription: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    
    var retryHandler: (() -> Void)?
    var parentView: UIView!
    
    class func getInstance(parentView: UIView) -> EmptyView {
        let emptyView = UINib(nibName: "EmptyView", bundle: nil)
            .instantiate(withOwner: nil, options: nil)[0] as! EmptyView
        
        parentView.addSubview(emptyView)
        emptyView.parentView = parentView
        emptyView.isHidden = true
        return emptyView
    }
    
    class func getInstance() -> EmptyView {
        let emptyView = UINib(nibName: "EmptyView", bundle: nil)
            .instantiate(withOwner: nil, options: nil)[0] as! EmptyView
        
        return emptyView
    }
    
    func setValues(image: UIImage? = nil, title: String? = nil, description: String? = nil,
                   retryButtonText: String? = nil, retryHandler: (() -> Void)? = nil) {
        
        if image != nil {
            imageView.image = image
        } else {
            imageView.isHidden = true
        }
        if title != nil {
            emptyViewTitle.text = title
        } else {
            emptyViewTitle.isHidden = true
        }
        if description != nil {
            emptyViewDescription.text = description
        } else {
            emptyViewDescription.isHidden = true
        }
        if retryButtonText != nil {
            retryButton.setTitle(retryButtonText, for: .normal)
        }
        if retryHandler != nil {
            self.retryHandler = retryHandler
            retryButton.isHidden = false
        } else {
            retryButton.isHidden = true
        }
    }
    
    func show(image: UIImage? = nil, title: String? = nil, description: String? = nil,
              retryButtonText: String? = nil, retryHandler: (() -> Void)? = nil) {
        
        setValues(image: image, title: title, description: description,
                  retryButtonText:  retryButtonText, retryHandler: retryHandler)
        
        frame = parentView.frame
        isHidden = false
        parentView.bringSubview(toFront: self)
    }
    
    func hide() {
        isHidden = true
        parentView.sendSubview(toBack: self)
    }

    @IBAction func onRetry(_ sender: UIButton) {
        if retryHandler != nil {
            retryHandler!()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Set frame here to support rotation
        if parentView != nil {
            frame = parentView.frame
        }
    }
    
}
