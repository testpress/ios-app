//
//  SuccessViewController.swift
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

class SuccessViewController: UIViewController {

    @IBOutlet weak var successDescriptionLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    var successDescription: String?
    var actionButtonText: String?
    var actionButtonClickHandler: (() -> Void)?
    var backButtonClickHandler: (() -> Void)!
    
    func initSuccessViewController(successDescription: String,
                                   actionButtonText: String? = nil,
                                   backButtonClickHandler: @escaping (() -> Void),
                                   actionButtonClickHandler: (() -> Void)? = nil) {
        
        self.successDescription = successDescription
        self.actionButtonText = actionButtonText
        self.backButtonClickHandler = backButtonClickHandler
        if actionButtonText != nil && actionButtonClickHandler == nil {
            self.actionButtonClickHandler = backButtonClickHandler
        } else {
            self.actionButtonClickHandler = actionButtonClickHandler
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        successDescriptionLabel.text = successDescription
        actionButton.isHidden = (actionButtonClickHandler == nil)
    }
    
    @IBAction func onClickActionButton(_ sender: UIButton) {
        actionButtonClickHandler!()
    }
    
    @IBAction func onClickBackButton() {
        backButtonClickHandler()
    }

}
