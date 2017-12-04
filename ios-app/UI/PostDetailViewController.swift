//
//  PostDetailViewController.swift
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

class PostDetailViewController: BaseWebViewController {
    
    @IBOutlet weak var contentView: UIView!
    
    var post: Post!
    var emptyView: EmptyView!
    var loading: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.center = CGPoint(x: view.center.x, y: webView.center.y)
        emptyView = EmptyView.getInstance(parentView: webView)
        loadHTMLContent()
    }
    
    override func getParentView() -> UIView {
        return contentView
    }
    
    func loadHTMLContent() {
        if loading {
            return
        }
        activityIndicator.startAnimating()
        loading = true
        TPApiClient.request(
            type: Post.self,
            endpointProvider: TPEndpointProvider(.get, url: post.url),
            completion: {
                post, error in
                if let error = error {
                    debugPrint(error.message ?? "No error")
                    debugPrint(error.kind)
                    var retryHandler: (() -> Void)?
                    if error.kind == .network {
                        retryHandler = {
                            self.emptyView.hide()
                            self.loadHTMLContent()
                        }
                    }
                    if (self.activityIndicator?.isAnimating)! {
                        self.activityIndicator?.stopAnimating()
                    }
                    let (image, title, description) = error.getDisplayInfo()
                    self.emptyView.show(image: image, title: title, description: description,
                                        retryHandler: retryHandler)
                    
                    self.loading = false
                    return
                }
                
                self.loading = false
                self.webView.loadHTMLString(
                    self.getFormattedContent(post!.contentHtml!),
                    baseURL: Bundle.main.bundleURL
                )
        })
    }
    
    func getFormattedContent(_ contentHtml: String) -> String {
        return WebViewUtils.getHeader() + WebViewUtils.getFormattedTitle(title: post.title) +
            WebViewUtils.getHtmlContentWithMargin(contentHtml)
    }
    
    @IBAction func back() {
        dismiss(animated: true, completion: nil)
    }
    
}
