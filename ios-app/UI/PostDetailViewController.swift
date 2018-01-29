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

import TTGSnackbar
import UIKit
import WebKit

class PostDetailViewController: BaseWebViewController, WKWebViewDelegate, WKScriptMessageHandler {
    
    @IBOutlet weak var editorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var bottomShadowView: UIView!
    @IBOutlet weak var commentBox: RichTextEditor!
    
    private let placeholder = "Write a comment..."
    
    var post: Post!
    var forum: Bool = false
    var emptyView: EmptyView!
    var loading: Bool = false
    var previousCommentsPager: CommentPager!
    var newCommentsPager: CommentPager!
    var comments = [Comment]()
    let imageUploadHelper = ImageUploadHelper()
    let bottomGradient = CAGradientLayer()
    let loadingDialogController = UIUtils.initProgressDialog(message: Strings.PLEASE_WAIT + "\n\n")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webViewDelegate = self
        commentBox.delegate = self
        commentBox.placeholder = placeholder
        imageUploadHelper.delegate = self
        activityIndicator.center = CGPoint(x: view.center.x, y: webView.center.y)
        emptyView = EmptyView.getInstance(parentView: webView)
        loadHTMLContent()
    }
    
    override func getParentView() -> UIView {
        return contentView
    }
    
    override func initWebView() {
        let contentController = WKUserContentController()
        contentController.add(self, name: "callbackHandler")
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        config.preferences.javaScriptEnabled = true
        
        webView = WKWebView( frame: self.contentView!.bounds, configuration: config)
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
    
    func getPreviousCommentsPager() -> CommentPager {
        if previousCommentsPager == nil {
            previousCommentsPager = CommentPager(post.commentsUrl)
            previousCommentsPager.queryParams.updateValue("-created", forKey: Constants.ORDER)
            let now = FormatDate.format(date: Date(),
                                        requiredFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'")
            
            previousCommentsPager.queryParams.updateValue(now, forKey: Constants.UNTIL)
        }
        return previousCommentsPager;
    }
    
    func getNewCommentsPager() -> CommentPager {
        if newCommentsPager == nil {
            newCommentsPager = CommentPager(post.commentsUrl)
        }
        //  Query comments after the latest comment we already have
        if (newCommentsPager.queryParams.isEmpty && comments.count != 0) {
            newCommentsPager.queryParams.updateValue(comments[comments.count - 1].created,
                                                     forKey: Constants.SINCE)
        }
        return newCommentsPager
    }
    
    func onFinishLoadingWebView() {
        loadPreviousComments()
    }
    
    func loadPreviousComments() {
        getPreviousCommentsPager().resources.removeAll()
        getPreviousCommentsPager().next(completion: {
            items, error in
            
            if let error = error {
                debugPrint(error.message ?? "No error")
                debugPrint(error.kind)
                var js = "hidePreviousCommentsLoading();\n"
                if self.post.commentsCount != 0 {
                    if error.kind == .network {
                        var loadButtonText: String
                        if self.comments.count == 0 {
                            loadButtonText = Strings.LOAD_COMMENTS
                        } else {
                            loadButtonText = Strings.LOAD_MORE_COMMENTS
                        }
                        js += "displayLoadMoreCommentsButton('" + loadButtonText + "');"
                        TTGSnackbar(message: Strings.NO_INTERNET_CONNECTION, duration: .middle)
                            .show()
                    } else {
                        TTGSnackbar(message: Strings.NETWORK_ERROR, duration: .middle).show()
                    }
                }
                self.evaluateJavaScript(js)
                return
            }
            
            var comments = Array(items!.values)
            comments = comments.sorted(by: {
                FormatDate.compareDate(dateString1:  $1.created!, dateString2: $0.created!)
            })
            comments.append(contentsOf: self.comments)
            self.comments = comments
            var html = ""
            for comment in comments {
                html += WebViewUtils.getCommentItemTags(comment)
            }
            html = WebViewUtils.formatHtmlToAppendInJavascript(html)
            var js = "hidePreviousCommentsLoading(); \n appendCommentItemsAtTop(\"\(html)\");"
            if self.comments.isEmpty && comments.isEmpty {
                js += "displayEmptyCommentsDescription();\n"
            }
            if self.getPreviousCommentsPager().hasMore {
                js += "\ndisplayLoadMoreCommentsButton('" + Strings.LOAD_MORE_COMMENTS + "');"
            }
            self.evaluateJavaScript(js)
        })
    }
    
    func loadNewComments() {
        var js = ""
        if self.comments.isEmpty {
            js += "hideEmptyCommentsDescription();\n"
        }
        js += "displayNewCommentsLoading()"
        evaluateJavaScript(js)
        getNewCommentsPager().next(completion: {
            items, error in
            
            if let error = error {
                debugPrint(error.message ?? "No error")
                debugPrint(error.kind)
                var js = "hideNewCommentsLoading();\n"
                if error.kind == .network {
                    TTGSnackbar(message: Strings.NO_INTERNET_CONNECTION, duration: .middle).show()
                    js += "displayLoadNewCommentsButton(\"" + Strings.LOAD_NEW_COMMENTS + "\");"
                } else {
                    TTGSnackbar(message: Strings.NETWORK_ERROR, duration: .middle).show()
                }
                self.evaluateJavaScript(js)
                return
            }
            
            if self.getNewCommentsPager().hasMore {
                self.loadNewComments()
                return
            }
            
            var comments = Array(items!.values)
            comments = comments.sorted(by: {
                FormatDate.compareDate(dateString1:  $0.created!, dateString2: $1.created!)
            })
            self.comments.append(contentsOf: comments)
            var html = ""
            for comment in comments {
                html += WebViewUtils.getCommentItemTags(comment)
            }
            html = WebViewUtils.formatHtmlToAppendInJavascript(html)
            var js = "hideNewCommentsLoading(); \n appendCommentItemsAtBottom(\"\(html)\");"
            if self.comments.isEmpty && comments.isEmpty {
                js += "displayEmptyCommentsDescription();\n"
            }
            self.evaluateJavaScript(js)
            // Scroll to bottom
            let scrollPoint = CGPoint(x: 0, y: self.webView.scrollView.contentSize.height -
                self.webView.frame.size.height)
            
            self.webView.scrollView.setContentOffset(scrollPoint, animated: false)
        })
    }
    
    func evaluateJavaScript(_ javascript: String) {
        self.webView.evaluateJavaScript(javascript) {
            (result, error) in
            if error != nil {
                debugPrint(error ?? "No Error Message")
                self.evaluateJavaScript("hidePreviousCommentsLoading();")
            }
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        
        if (message.name == "callbackHandler") {
            let body = message.body
            if let message = body as? String {
                switch(message) {
                case "LoadMoreComments":
                    print("LoadMoreComments")
                    loadPreviousComments()
                    break
                case "LoadNewComments":
                    loadNewComments()
                    break
                default:
                    break
                }
            }
        }
    }
    
    @IBAction func postComment(_ sender: Any) {
        commentBox.endEditing(true)
        let comment: String? = commentBox.text
        if (comment == nil) ||
            (comment!.elementsEqual("") || comment!.elementsEqual(placeholder)) {
            
            return
        }
        present(loadingDialogController, animated: true)
        postComment(comment!)
    }
    
    func postComment(_ comment: String) {
        TPApiClient.postComment(
            comment: comment,
            commentsUrl: post.commentsUrl,
            completion: { comment, error in
                
                if let error = error {
                    debugPrint(error.message ?? "No error")
                    debugPrint(error.kind)
                    self.loadingDialogController.dismiss(animated: false)
                    let (_, title, _) = error.getDisplayInfo()
                    TTGSnackbar(message: title, duration: .middle).show()
                    return
                }
                
                self.commentBox.text = ""
                self.loadingDialogController.dismiss(animated: false)
                self.getNewCommentsPager().reset()
                self.loadNewComments()
        })
    }
    
    @IBAction func uploadImage(_ sender: UIButton) {
        imageUploadHelper.showImagePicker(viewController: self,
                                          loadingDialogController: loadingDialogController)
    }
    
    func getTitle() -> String {
        if forum {
            return WebViewUtils.getFormattedDiscussionTitle(post: post)
        }
        return WebViewUtils.getFormattedTitle(title: post.title)
    }
    
    func getFormattedContent(_ contentHtml: String) -> String {
        var html = WebViewUtils.getHeader() + getTitle() +
            WebViewUtils.getHtmlContentWithMargin(contentHtml)
        
        html += "<hr style='margin-top:20px;'>"
        html += WebViewUtils.getCommentHeadingTags(headingText: Strings.COMMENTS);
        
        html += "<div id='empty_comments_description' style='display:none;'>" +
                    "Be the first to post a comment</div>"
        
        html += WebViewUtils.getLoadingProgressBar(className: "preview_comments_loading_layout")
        html += "<div class='load_more_comments_layout' style='display:none;'>" +
                    "<hr>" +
                    "<div class='load_more_comments' onclick='loadMoreComments()'></div>" +
                    "<hr>" +
                "</div>"
        
        html += "<div id='comments_layout'></div>"
        html += WebViewUtils.getLoadingProgressBar(className: "new_comments_loading_layout",
                                                   visible: false)
        
        html += "<div class='load_new_comments_layout' style='display:none;'>" +
                    "<div class='load_new_comments' onclick='loadNewComments()'></div>" +
                "</div>"
        
        return html
    }
    
    @IBAction func back() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        // Add gradient shadow layer to the shadow container view
        UIUtils.updateBottomShadow(bottomShadowView: bottomShadowView,
                                   bottomGradient: bottomGradient)
    }
    
}

extension PostDetailViewController: RichTextEditorDelegate {
    
    func heightDidChange(_ editor: RichTextEditor, heightDidChange height: CGFloat) {
        editorHeightConstraint.constant = height + 5
    }
}

extension PostDetailViewController: ImageUploadHelperDelegate {
    
    func imageUploadHelper(_ helper: ImageUploadHelper, didFinishUploadImage imageUrl: String) {
        postComment(WebViewUtils.appendImageTag(imageUrl: imageUrl))
    }
}
