//
//  ReviewQuestionsViewController.swift
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
import Alamofire

class ReviewQuestionsViewController: BaseQuestionsViewController, WKScriptMessageHandler, BookmarkDelegate {
    
    var previousCommentsPager: CommentPager!
    var newCommentsPager: CommentPager!
    var comments = [Comment]()
    var bookmarkHelper: BookmarkHelper!
    let imageUploadHelper = ImageUploadHelper()
    let loadingDialogController = UIUtils.initProgressDialog(message: Strings.PLEASE_WAIT + "\n\n")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupHelpers()
        loadWebViewContent()
    }
    
    private func setupHelpers() {
        imageUploadHelper.delegate = self
        bookmarkHelper = BookmarkHelper(viewController: self)
        bookmarkHelper.delegate = self
    }
    
    private func loadWebViewContent() {
        let htmlString = WebViewUtils.getQuestionHeader() + getAdditionalHeaders() + getHtml()
        
        webView.loadHTMLString(htmlString, baseURL: Bundle.main.bundleURL)
    }
    
    func getAdditionalHeaders() -> String {
        return Constants.BOOKMARKS_ENABLED ? WebViewUtils.getBookmarkHeader() : ""
    }
    
    override func initWebView() {
        let contentController = WKUserContentController()
        contentController.add(self, name: "callbackHandler")
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        config.preferences.javaScriptEnabled = true
        
        webView = WKWebView( frame: self.containerView!.bounds, configuration: config)
    }
    
    override func onFinishLoadingWebView() {
        super.onFinishLoadingWebView()
        loadPreviousComments()
    }
    
    func getPreviousCommentsPager() -> CommentPager {
        if previousCommentsPager == nil {
            attemptItem.question.commentsUrl =
            TPEndpointProvider.getCommentsUrl(questionId: attemptItem.question.id)
            
            previousCommentsPager = CommentPager(attemptItem.question.commentsUrl)
            previousCommentsPager.queryParams.updateValue("-created", forKey: Constants.ORDER)
            let now = FormatDate.format(date: Date(),
                                        requiredFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'")
            
            previousCommentsPager.queryParams.updateValue(now, forKey: Constants.UNTIL)
        }
        return previousCommentsPager;
    }
    
    func getNewCommentsPager() -> CommentPager {
        if newCommentsPager == nil {
            newCommentsPager = CommentPager(attemptItem.question.commentsUrl)
        }
        //  Query comments after the latest comment we already have
        if (newCommentsPager.queryParams.isEmpty && comments.count != 0) {
            newCommentsPager.queryParams.updateValue(comments[0].created, forKey: Constants.SINCE)
        }
        return newCommentsPager
    }
    
    func loadPreviousComments() {
        getPreviousCommentsPager().resources.removeAll()
        getPreviousCommentsPager().next(completion: {
            items, error in
            
            if let error = error {
                debugPrint(error.message ?? "No error")
                debugPrint(error.kind)
                var js = "hidePreviousCommentsLoading();\n"
                if error.kind == .network && self.attemptItem.commentsCount != 0 {
                    var loadButtonText: String
                    if self.comments.count == 0 {
                        loadButtonText = Strings.LOAD_COMMENTS
                    } else {
                        loadButtonText = Strings.LOAD_MORE_COMMENTS
                    }
                    js += "displayLoadMoreCommentsButton('" + loadButtonText + "');"
                }
                self.evaluateJavaScript(js)
                return
            }
            
            var comments = Array(items!.values)
            comments = comments.sorted(by: {
                FormatDate.compareDate(dateString1:  $0.created!, dateString2: $1.created!)
            })
            self.comments.append(contentsOf: comments)
            var html = ""
            for comment in comments {
                html += WebViewUtils.getCommentItemTags(comment, seperatorAtTop: true)
            }
            html = WebViewUtils.formatHtmlToAppendInJavascript(html)
            var js = "hidePreviousCommentsLoading(); \n appendCommentItemsAtBottom(\"\(html)\");"
            if self.getPreviousCommentsPager().hasMore {
                js += "\ndisplayLoadMoreCommentsButton('" + Strings.LOAD_MORE_COMMENTS + "');"
            }
            self.evaluateJavaScript(js)
        })
    }
    
    func loadNewComments() {
        evaluateJavaScript("displayNewCommentsLoading()")
        getNewCommentsPager().next(completion: {
            items, error in
            
            if let error = error {
                debugPrint(error.message ?? "No error")
                debugPrint(error.kind)
                var js = "hideNewCommentsLoading();\n"
                if self.attemptItem.commentsCount == 0 {
                } else if error.kind == .network {
                    js += "displayLoadNewCommentsButton(\"" + Strings.LOAD_NEW_COMMENTS + "\");"
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
            var html = ""
            for comment in comments {
                html += WebViewUtils.getCommentItemTags(comment, seperatorAtTop: true)
            }
            comments.append(contentsOf: self.comments)
            self.comments = comments
            html = WebViewUtils.formatHtmlToAppendInJavascript(html)
            let js = "hideNewCommentsLoading(); \n appendCommentItemsAtTop(\"\(html)\");"
            self.evaluateJavaScript(js)
        })
    }
    
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        
        if (message.name == "callbackHandler") {
            let body = message.body
            if let message = body as? String {
                switch(message) {
                case "LoadMoreComments":
                    loadPreviousComments()
                    break
                case "LoadNewComments":
                    loadNewComments()
                    break
                case "InsertImage":
                    uploadImage()
                    break
                default:
                    bookmarkJavascriptListener(message: message)
                    break
                }
            } else if let dict = body as? Dictionary<String, AnyObject> {
                let comment = dict["comment"] as! String
                present(loadingDialogController, animated: true)
                postComment(comment)
            }
        }
    }
    
    func bookmarkJavascriptListener(message: String) {
        bookmarkHelper.javascriptListener(message: message, bookmarkId: attemptItem.bookmarkId)
    }
    
    func postComment(_ comment: String) {
        TPApiClient.postComment(
            comment: comment,
            commentsUrl: attemptItem.question.commentsUrl,
            completion: { comment, error in
                
                if let error = error {
                    self.loadingDialogController.dismiss(animated: false)
                    let (_, title, _) = error.getDisplayInfo()
                    let snackbar = TTGSnackbar(message: title, duration: .middle)
                    snackbar.show()
                    return
                }
                
                self.evaluateJavaScript("clearCommentBox();")
                self.loadingDialogController.dismiss(animated: false)
                self.getNewCommentsPager().reset()
                self.loadNewComments()
            })
    }
    
    func uploadImage() {
        imageUploadHelper.showImagePicker(viewController: self,
                                          loadingDialogController: loadingDialogController)
    }
    
    func getHtml() -> String {
        guard let attemptItem = attemptItem, let attemptQuestion = attemptItem.question else {
                return ""
            }
        
        var html: String = "<div style='padding-left: 5px; padding-right: 5px;'>"
        html += "<div style='overflow:scroll'>"
        
        html += getHtmlAboveQuestion()
        html += getDirectionHtml(attemptQuestion)
        html += getQuestionHtml(attemptQuestion)
        html += getAnswersHtml(attemptItem: attemptItem)
        html += getEssayHtml(attemptQuestion: attemptQuestion)
        html += getAnswerDetailsHtml(attemptItem: attemptItem)
        html += getMarkingDetailsHtml(attemptItem: attemptItem)
        html += getExplanationSectionHtml(attemptQuestion)
        html += getSubjectSectionHtml(attemptQuestion) + "</div>"
        html += getDividerHtml()
        html += getCommentBoxHtml()
        html += getLoadNewCommentsHtml()
        html += getCommentsLayoutHtml()
        html += getLoadMoreCommentsHtml() + "</div>"
        html += getDividerHtml() + "</div>"

        return html
    }
    
    func getHtmlAboveQuestion() -> String {
        // Add index
        var html = "<div class='review-question-index'>\((attemptItem!.index) + 1)</div>"
        if (Constants.BOOKMARKS_ENABLED) {
            let attemptItemBookmarked = attemptItem!.bookmarkId != nil
            html += WebViewUtils.getBookmarkButtonWithTags(bookmarked: attemptItemBookmarked)
        }
        return html
    }
    
    private func getDirectionHtml(_ question: AttemptQuestion) -> String {
        guard let direction = question.direction, !direction.isEmpty else {
            return ""
        }
        
        return "<div class='question' style='padding-bottom: 0px;'>" +
               question.getLanguageBasedDirection(self.language) +
               "</div>"
    }
    
    private func getQuestionHtml(_ question: AttemptQuestion) -> String {
        return "<div class='question'>" +
               question.getLanguageBasedQuestion(self.language) +
               "</div>"
    }
    
    func getAnswersHtml(attemptItem: AttemptItem) -> String {
        var attemptQuestion = attemptItem.question!
        var html = ""

        for (i, attemptAnswer) in attemptQuestion.answers.enumerated() {
            if attemptQuestion.isSingleMcq || attemptQuestion.isMultipleMcq {
                var optionColor: String?
                if attemptItem.selectedAnswers.contains(attemptAnswer.id) {
                    optionColor = attemptAnswer.isCorrect ? Colors.MATERIAL_GREEN : Colors.MATERIAL_RED
                }
                html += "\n" + WebViewUtils.getOptionWithTags(
                    optionText: attemptAnswer.getTextHtml(attemptQuestion, self.language),
                    index: i,
                    color: optionColor
                )
            } else if !attemptQuestion.isNumerical {
                if i == 0 {
                    html += "<table width='100%' style='margin-top:0px; margin-bottom:15px;'>"
                        + WebViewUtils.getShortAnswerHeadersWithTags()
                }
                html += WebViewUtils.getShortAnswersWithTags(
                    shortAnswerText: attemptAnswer.getTextHtml(attemptQuestion, self.language),
                    marksAllocated: attemptAnswer.marks!
                )
                if i == attemptQuestion.answers.count - 1 {
                    html += "</table>"
                }
            }
        }
        return html
    }
    
    func getEssayHtml(attemptQuestion: AttemptQuestion) -> String {
        var html = ""
        if attemptQuestion.isEssayType {
            html += getUserEssayAnswer()
            html += getEssayMarks()
        }
        return html
    }

    func getAnswerDetailsHtml(attemptItem: AttemptItem) -> String {
        var attemptQuestion = attemptItem.question!
        var html = ""
        if attemptQuestion.isShortAnswer || attemptQuestion.isNumerical {
            html += "<div style='display:box; display:-webkit-box; margin-bottom:10px;'>" +
                WebViewUtils.getReviewHeadingTags(headingText: Strings.YOUR_ANSWER) +
                (attemptItem.shortText ?? "") +
                "</div>"
        }
        return html
    }

    func getMarkingDetailsHtml(attemptItem: AttemptItem) -> String {
        var question = attemptItem.question!
        var html = ""
        if question.isSingleMcq || question.isMultipleMcq || question.isNumerical {
            html += "<div style='display:block;'>" +
                WebViewUtils.getReviewHeadingTags(headingText: Strings.CORRECT_ANSWER) +
            getCorrectAnswersHtml(attemptQuestion: attemptItem.question!) + "</div>"
        }
        if question.isShortAnswer || question.isNumerical {
            html += "<div style='display:box; display:-webkit-box; margin-bottom:10px;'>" +
                WebViewUtils.getReviewHeadingTags(headingText: Strings.MARKS_AWARDED) +
                (attemptItem.marks ?? "")! +
                "</div>"
            if question.isShortAnswer {
                let note = question.isCaseSensitive ?
                    Strings.CASE_SENSITIVE : Strings.CASE_INSENSITIVE

                html += "<div style='display:box; display:-webkit-box; margin-bottom:10px;'>" +
                    WebViewUtils.getReviewHeadingTags(headingText: Strings.NOTE) +
                    note +
                    "</div>"
            }
        }
        return html
    }
    
    private func getExplanationSectionHtml(_ question: AttemptQuestion) -> String {
        var html = ""
        let explanationHtml = question.getExplanationHtml(self.language)
        if let explanationHtml = explanationHtml, !explanationHtml.isEmpty {
            html += WebViewUtils.getReviewHeadingTags(headingText: Strings.EXPLANATION)
            html += "<div class='review-explanation'>"
            html += explanationHtml
            html += "</div>"
        }
        return html
    }

    private func getSubjectSectionHtml(_ question: AttemptQuestion) -> String {
        var html = ""
        if !question.subject.isEmpty && question.subject != "Uncategorized" {
            html += WebViewUtils.getReviewHeadingTags(headingText: Strings.SUBJECT_HEADING)
            html += "<div class='subject'>"
            html += question.subject
            html += "</div>"
        }
        return html
    }
    
    private func getCommentBoxHtml() -> String {
        var html = WebViewUtils.getCommentHeadingTags(headingText: Strings.COMMENTS)
        html += "<div class='comment_box_layout'>" +
                "<div><span class='icon-add-a-photo' onclick='insertImage()'></span></div>" +
                "<div contentEditable='true' class='comment_box' " +
                "data-placeholder='Write a comment...'></div>" +
                "<div><span class='icon-paper-plane' onclick='sendComment()'></span></div>" +
                "</div>"
        
        return html
    }

    private func getLoadNewCommentsHtml() -> String {
        var html = WebViewUtils.getLoadingProgressBar(className: "new_comments_loading_layout",
                                                      visible: false)
        html += "<div class='load_new_comments_layout' style='display:none;'>" +
                "<hr>" +
                "<div class='load_new_comments' onclick='loadNewComments()'></div>" +
                "</div>"
        
        return html
    }
    
    private func getCommentsLayoutHtml() -> String {
        return "<div id='comments_layout'></div>"
    }

    private func getLoadMoreCommentsHtml() -> String {
        var html = WebViewUtils.getLoadingProgressBar(className: "preview_comments_loading_layout")
        html += "<div class='load_more_comments_layout' style='display:none;'>" +
                "<hr>" +
                "<div class='load_more_comments' onclick='loadMoreComments()'></div>" +
                "</div>"
        
        return html
    }
    
    private func getDividerHtml() -> String {
        return "<hr style='margin-top:20px;'>"
    }
    
    
    func getUserEssayAnswer() -> String {
        return "<div style='display:box; display:-webkit-box; margin-bottom:10px;'>" +
        WebViewUtils.getReviewHeadingTags(headingText: Strings.YOUR_ANSWER) +
        (attemptItem.essayText ?? "") +
        "</div>"
    }
    
    func getEssayMarks() -> String {
        return "<div style='display:box; display:-webkit-box; margin-bottom:10px;'>" +
        WebViewUtils.getReviewHeadingTags(headingText: Strings.MARKS_AWARDED) +
        (attemptItem.marks ?? "")! +
        "</div>"
    }
    
    func getCorrectAnswersHtml(attemptQuestion: AttemptQuestion) -> String {
        var correctAnswerHtml = ""
        
        if attemptQuestion.isSingleMcq || attemptQuestion.isMultipleMcq {
            correctAnswerHtml = attemptQuestion.answers.enumerated()
                .filter { $0.element.isCorrect }
                .map { WebViewUtils.getCorrectAnswerIndexWithTags(index: $0.offset) }
                .joined()
        } else if attemptQuestion.isNumerical {
            correctAnswerHtml = attemptQuestion.answers.first?.getTextHtml(attemptQuestion, self.language) ?? ""
        }
        
        return correctAnswerHtml
    }
    
    func onClickBookmarkButton() {
        self.evaluateJavaScript("hideBookmarkButton();")
    }
    
    func getBookMarkParams() -> Parameters? {
        var parameters: Parameters = Parameters()
        parameters["object_id"] = self.attemptItem.id
        parameters["content_type"] = ["model": "userselectedanswer", "app_label": "exams"]
        return parameters
    }
    
    func updateBookmark(bookmarkId: Int?) {
        self.attemptItem.bookmarkId = bookmarkId
        self.evaluateJavaScript("updateBookmarkButtonState(\(bookmarkId != nil));")
    }
    
    func displayBookmarkButton() {
        self.evaluateJavaScript("displayBookmarkButton();")
    }
    
    func displayMoveButton() {
        self.evaluateJavaScript("displayMoveButton();")
    }
    
    func onClickMoveButton() {}
    func removeBookmark() {}
    func displayRemoveButton() {}
}

extension ReviewQuestionsViewController: ImageUploadHelperDelegate {
    func imageUploadHelper(_ helper: ImageUploadHelper, didFinishUploadImage imageUrl: String) {
        postComment(WebViewUtils.appendImageTag(imageUrl: imageUrl))
    }
}
