//
//  BaseQuestionsViewController.swift
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
import WebKit
import CourseKit

class BaseQuestionsViewController: BaseWebViewController, WKWebViewDelegate {

    @IBOutlet weak var topShadowView: UIView!
    @IBOutlet weak var bottomShadowView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    var attemptItem: AttemptItem!
    var language: Language?
    let topGradient = CAGradientLayer()
    let bottomGradient = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webViewDelegate = self
    }
    
    override func getParentView() -> UIView {
        return containerView
    }
    
    override func viewDidLayoutSubviews() {
        // Add gradient shadow layer to the shadow container view
        topGradient.frame = topShadowView.bounds
        topGradient.colors = [UIColor.black.cgColor, UIColor.white.cgColor]
        topShadowView.layer.insertSublayer(topGradient, at: 0)
        
        bottomGradient.frame = bottomShadowView.bounds
        bottomGradient.colors = [UIColor.white.cgColor, UIColor.black.cgColor]
        bottomShadowView.layer.insertSublayer(bottomGradient, at: 0)
    }
    
    func onFinishLoadingWebView() {
        // Bring top & bottom shadow to front
        view.bringSubviewToFront(bottomShadowView)
        view.bringSubviewToFront(topShadowView)
    }

}
