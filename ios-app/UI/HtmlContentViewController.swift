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
import  Alamofire
import RealmSwift

class HtmlContentViewController: BaseWebViewController {
    
    var content: Content!
    var emptyView: EmptyView!
    var loading: Bool = false
    var contentAttemptCreationDelegate: ContentAttemptCreationDelegate?
    var bookmarkHelper: BookmarkHelper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emptyView = EmptyView.getInstance(parentView: webView)
        webViewDelegate = self
        bookmarkHelper = BookmarkHelper(viewController: self)
        bookmarkHelper.delegate = self
        checkContentType()
    }
    
    override func initWebView() {
        let contentController = WKUserContentController()
        contentController.add(self, name: "callbackHandler")
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        config.preferences.javaScriptEnabled = true
        
        webView = WKWebView( frame: parentView.bounds, configuration: config)
    }
    
    func checkContentType() {
        if content.htmlObject != nil {
            loadHTMLContent()
        } else if content.video != nil {
            displayVideoContent()
        }
    }
    
    func loadHTMLContent() {
        title = content.htmlObject?.title
        if (content.htmlObject != nil) {
            self.webView.loadHTMLString(
                self.getFormattedContent(content.htmlObject!.textHtml),
                baseURL: Bundle.main.bundleURL
            )
            return
        }
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
                    self.getFormattedContent(htmlContent!.textHtml),
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
    
    func createContentAttempt() {
            let attemptsUrl = String(format: "%@%@%d/attempts/", Constants.BASE_URL , TPEndpoint.getContents.urlPath, content.id)
        TPApiClient.request(
            type: ContentAttempt.self,
            endpointProvider: TPEndpointProvider(.post, url: attemptsUrl),
            completion: {
                contentAttempt, error in
                if let error = error {
                    debugPrint(error.message ?? "No error")
                    debugPrint(error.kind)
                    return
                }
                
                if self.content.attemptsCount == 0 {
                    self.contentAttemptCreationDelegate?.newAttemptCreated()
                }
        })
    }
    
    func getFormattedContent(_ contentHtml: String) -> String {
        var html = WebViewUtils.getHeader()
        if Constants.BOOKMARKS_ENABLED {
            html += WebViewUtils.getBookmarkHeader()
        }
        let bookmarked = content.bookmarkId.value != nil
        html += WebViewUtils.getFormattedTitle(
            title: title!,
            withBookmarkButton: Constants.BOOKMARKS_ENABLED,
            withBookmarkedState: bookmarked
        )
        return html + WebViewUtils.getHtmlContentWithMargin(contentHtml)
    }
    
    func bookmarkJavascriptListener(message: String) {
        bookmarkHelper.javascriptListener(message: message, bookmarkId: content.bookmarkId.value)
    }
    
}

extension HtmlContentViewController: WKWebViewDelegate {
    
    func onFinishLoadingWebView() {
        createContentAttempt()
    }
}

extension HtmlContentViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        
        if (message.name == "callbackHandler") {
            let body = message.body
            if let message = body as? String {
                bookmarkJavascriptListener(message: message)
            }
        }
    }
}


extension HtmlContentViewController: BookmarkDelegate {
    func getBookMarkParams() -> Parameters? {
        var parameters: Parameters = Parameters()
        parameters["object_id"] = content.id
        parameters["content_type"] = ["model": "chaptercontent", "app_label": "courses"]
        print("Parameters : \(parameters)")
        return parameters
    }
    
    func onClickMoveButton() {
        self.evaluateJavaScript("hideMoveButton();")
    }
    
    func removeBookmark() {
        self.evaluateJavaScript("hideRemoveButton();")
    }
    
    func displayRemoveButton() {
        self.evaluateJavaScript("displayRemoveButton();")
    }
    
    func onClickBookmarkButton() {
        self.evaluateJavaScript("hideBookmarkButton();")
    }
    
    func updateBookmark(bookmarkId: Int?) {
        self.content.bookmarkId = RealmOptional<Int>(bookmarkId)
        self.evaluateJavaScript("updateBookmarkButtonState(\(bookmarkId != nil));")
    }
    
    func displayBookmarkButton() {
        self.evaluateJavaScript("displayBookmarkButton();")
    }
    
    func displayMoveButton() {
        self.evaluateJavaScript("displayMoveButton();")
    }
}
