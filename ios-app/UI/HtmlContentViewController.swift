//
//  HtmlContentViewController.swift
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

class HtmlContentViewController: BaseWebViewController {
    
    var content: Content!
    var emptyView: EmptyView!
    var loading: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emptyView = EmptyView.getInstance(parentView: webView)
        checkContentType()
    }
    
    func checkContentType() {
        if content.htmlContentTitle != nil {
            loadHTMLContent()
        } else if content.video != nil {
            displayVideoContent()
        }
    }
    
    func loadHTMLContent() {
        title = content.htmlContentTitle
        if loading {
            return
        }
        activityIndicator.startAnimating()
        loading = true
        TPApiClient.request(
            type: HtmlContent.self,
            endpointProvider: TPEndpointProvider(.get, url: content.htmlContentUrl),
            completion: {
                htmlContent, error in
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
                    self.getFormattedContent(htmlContent!.textHtml!),
                    baseURL: Bundle.main.bundleURL
                )
            })
    }
    
    func displayVideoContent() {
        title = content.video!.title
        if !Reachability.isConnectedToNetwork() {
            let retryHandler = {
                self.emptyView.hide()
                self.viewDidLoad()
            }
            emptyView.show(image: Images.TestpressNoWifi.image,
                           title: Strings.NETWORK_ERROR,
                           description: Strings.PLEASE_CHECK_INTERNET_CONNECTION,
                           retryHandler: retryHandler)
            
            return
        }
        let videoContentHtml = "<div class='videoWrapper'>" + content.video!.embedCode + "</div>"
        webView.loadHTMLString(
            getFormattedContent(videoContentHtml),
            baseURL: Bundle.main.bundleURL
        )
    }
    
    func getFormattedContent(_ contentHtml: String) -> String {
        return WebViewUtils.getHeader() + WebViewUtils.getFormattedTitle(title: title!) +
            WebViewUtils.getHtmlContentWithMargin(contentHtml)
    }
    
}
