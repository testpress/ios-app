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
import AVFoundation
import AVKit


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
        checkContentType()
    }
    
    @objc func buttonAction(sender: UIButton!) {
        self.playVideo(url: content.video!.url)
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
        if content.htmlContentTitle != nil {
            loadHTMLContent()
        } else if content.video != nil {
            if content.video!.url != nil {
                let button = UIButton(frame: CGRect(x: webView.scrollView.center.x-50, y: webView.scrollView.center.y, width: 110, height: 50))
                button.backgroundColor = Colors.getRGB(Colors.PRIMARY)
                button.setTitle("Play Video", for: .normal)
                button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
                webView.scrollView.addSubview(button)
            }
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
    
    private func playVideo(url: String) {
        let video_url = URL(string: url)
        let player = AVPlayer(url: video_url!)
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])
        let playerController = AVPlayerViewController()
        playerController.player = player
        self.present(playerController, animated: true) {
            player.play()
        }
    }
    
    func createContentAttempt() {
        TPApiClient.request(
            type: ContentAttempt.self,
            endpointProvider: TPEndpointProvider(.post, url: content.attemptsUrl),
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
        let bookmarked = content.bookmarkId != nil
        html += WebViewUtils.getFormattedTitle(
            title: title!,
            withBookmarkButton: Constants.BOOKMARKS_ENABLED,
            withBookmarkedState: bookmarked
        )
        return html + WebViewUtils.getHtmlContentWithMargin(contentHtml)
    }
    
    func bookmarkJavascriptListener(message: String) {
        bookmarkHelper.javascriptListener(message: message, bookmarkId: content.bookmarkId)
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
