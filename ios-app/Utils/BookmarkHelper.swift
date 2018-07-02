//
//  BookmarkHelper.swift
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

import Alamofire
import TTGSnackbar
import UIKit

class BookmarkHelper {
    
    var viewController: UIViewController!
    var slidingViewController: BookmarksSlidingViewController!
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    // Javascript call back handler
    @discardableResult
    func javascriptListener(message: String, bookmark: Bookmark) -> Bool {
        switch(message) {
            case "MoveBookmark":
                onClickMoveButton(bookmark: bookmark)
                return true
            case "RemoveBookmark":
                onClickRemoveButton(bookmark: bookmark)
                return true
            default:
                return false
        }
    }
    
    func onClickMoveButton(bookmark: Bookmark) {
        if let questionViewController = viewController as? BookmarkedQuestionViewController {
            questionViewController.evaluateJavaScript("hideMoveButton();")
        } else if viewController is AttachmentDetailViewController {
            let attachmentViewController = viewController as! AttachmentDetailViewController
            attachmentViewController.moveButton.isHidden = true
            attachmentViewController.moveAnimationView.isHidden = false
        } else {
            let htmlViewController = viewController as! BookmarkedHtmlContentViewController
            htmlViewController.evaluateJavaScript("hideMoveButton();")
        }
        showFoldersList(bookmark: bookmark)
    }
    
    func onClickRemoveButton(bookmark: Bookmark) {
        if slidingViewController == nil {
            let navigationViewController = viewController.presentingViewController?
                .presentedViewController as! UINavigationController
            
            slidingViewController = navigationViewController.viewControllers.first
                as! BookmarksSlidingViewController
        }
        UIUtils.showSimpleAlert(
            title: Strings.ARE_YOU_SURE,
            message: Strings.WANT_TO_DELETE_BOOKMARK,
            viewController: slidingViewController,
            positiveButtonText: Strings.YES,
            positiveButtonStyle: .destructive,
            negativeButtonText: Strings.NO,
            cancelable: true,
            cancelHandler: #selector(slidingViewController.closeAlert),
            completion: { action in
                self.removeBookmark(bookmark: bookmark)
        })
    }
    
    func removeBookmark(bookmark: Bookmark) {
        if let questionViewController = viewController as? BookmarkedQuestionViewController {
            questionViewController.evaluateJavaScript("hideRemoveButton();")
        } else if viewController is AttachmentDetailViewController {
            let attachmentViewController = viewController as! AttachmentDetailViewController
            attachmentViewController.removeButton.isHidden = true
            attachmentViewController.removeAnimationView.isHidden = false
        } else {
            let htmlViewController = viewController as! BookmarkedHtmlContentViewController
            htmlViewController.evaluateJavaScript("hideRemoveButton();")
        }
        deleteBookmark(bookmarkId: bookmark.id)
    }
    
    // Javascript call back handler
    @discardableResult
    func javascriptListener(message: String, bookmarkId: Int?) -> Bool {
        switch(message) {
        case "ClickedBookmarkButton":
            onClickBookmarkButton(bookmarkId: bookmarkId)
            return true
        default:
            return false
        }
    }
    
    func onClickBookmarkButton(bookmarkId: Int?) {
        if let questionViewController = viewController as? ReviewQuestionsViewController {
            questionViewController.evaluateJavaScript("hideBookmarkButton();")
        } else if viewController is AttachmentDetailViewController {
            let attachmentViewController = viewController as! AttachmentDetailViewController
            attachmentViewController.bookmarkButton.isHidden = true
            attachmentViewController.bookmarkAnimationContainer.isHidden = false
        } else {
            let htmlViewController = viewController as! HtmlContentViewController
            htmlViewController.evaluateJavaScript("hideBookmarkButton();")
        }
        if bookmarkId != nil {
            deleteBookmark(bookmarkId: bookmarkId!)
        } else {
            showFoldersList()
        }
    }
    
    static func updateBookmark(with bookmarkId: Int?, in viewController: UIViewController) {
        if let questionViewController = viewController as? ReviewQuestionsViewController {
            questionViewController.attemptItem.bookmarkId = bookmarkId
            setBookmarkButtonState(bookmarkId: bookmarkId, webViewController: questionViewController)
        } else if viewController is AttachmentDetailViewController {
            let attachmentViewController = viewController as! AttachmentDetailViewController
            attachmentViewController.udpateBookmarkButtonState(bookmarkId: bookmarkId)
        } else {
            let htmlViewController = viewController as! HtmlContentViewController
            htmlViewController.content.bookmarkId = bookmarkId
            setBookmarkButtonState(bookmarkId: bookmarkId, webViewController: htmlViewController)
        }
    }
    
    static func setBookmarkButtonState(bookmarkId: Int?, webViewController: BaseWebViewController) {
        let bookmarked = bookmarkId != nil
        webViewController.evaluateJavaScript("updateBookmarkButtonState(\(bookmarked));")
    }
    
    static func displayBookmarkButton(in viewController: UIViewController) {
        if let questionViewController = viewController as? ReviewQuestionsViewController {
            questionViewController.evaluateJavaScript("displayBookmarkButton();")
        } else if viewController is AttachmentDetailViewController {
            let attachmentViewController = viewController as! AttachmentDetailViewController
            attachmentViewController.bookmarkAnimationContainer.isHidden = true
            attachmentViewController.bookmarkButton.isHidden = false
        } else {
            let htmlViewController = viewController as! HtmlContentViewController
            htmlViewController.evaluateJavaScript("displayBookmarkButton();")
        }
    }
    
    public static func displayMoveButton(in viewController: UIViewController) {
        if let questionViewController = viewController as? BookmarkedQuestionViewController {
            questionViewController.evaluateJavaScript("displayMoveButton();")
        } else if viewController is AttachmentDetailViewController {
            let attachmentViewController = viewController as! AttachmentDetailViewController
            attachmentViewController.moveAnimationView.isHidden = true
            attachmentViewController.moveButton.isHidden = false
        } else {
            let htmlViewController = viewController as! BookmarkedHtmlContentViewController
            htmlViewController.evaluateJavaScript("displayMoveButton();")
        }
    }
    
    func displayRemoveButton() {
        if let questionViewController = viewController as? BookmarkedQuestionViewController {
            questionViewController.evaluateJavaScript("displayRemoveButton();")
        } else if viewController is AttachmentDetailViewController {
            let attachmentViewController = viewController as! AttachmentDetailViewController
            attachmentViewController.removeAnimationView.isHidden = true
            attachmentViewController.removeButton.isHidden = false
        } else {
            let htmlViewController = viewController as! BookmarkedHtmlContentViewController
            htmlViewController.evaluateJavaScript("displayRemoveButton();")
        }
    }
    
    func showFoldersList(bookmark: Bookmark? = nil) {
        let storyboard = UIStoryboard(name: Constants.BOOKMARKS_STORYBOARD, bundle: nil)
        let navigationController = storyboard.instantiateViewController(withIdentifier:
            Constants.BOOKMARK_FOLDER_NAVIGATION_CONTROLLER) as! UINavigationController
        
        let foldersTableViewController = navigationController.viewControllers.first
            as! BookmarkFolderTableViewController
        
        foldersTableViewController.bookmark = bookmark
        foldersTableViewController.sourceViewController = viewController
        viewController.present(navigationController, animated: true, completion: nil)
    }
    
    func deleteBookmark(bookmarkId: Int) {
        let urlPath = TPEndpointProvider.getBookmarkPath(bookmarkId: bookmarkId)
        TPApiClient.apiCall(
            endpointProvider: TPEndpointProvider(.delete, urlPath: urlPath),
            completion: {
                void, error in
                if let error = error {
                    debugPrint(error.message ?? "No error")
                    debugPrint(error.kind)
                    if self.slidingViewController == nil {
                        BookmarkHelper.displayBookmarkButton(in: self.viewController)
                    } else {
                        self.displayRemoveButton()
                    }
                    let (_, _, description) = error.getDisplayInfo()
                    TTGSnackbar(message: description, duration: .middle).show()
                    return
                }
                
                if self.slidingViewController == nil {
                    BookmarkHelper.updateBookmark(with: nil, in: self.viewController)
                } else {
                    TTGSnackbar(
                        message: Strings.BOOKMARK_DELETED_SUCCESSFULLY,
                        duration: .middle
                    ).show()
                    self.slidingViewController.onBookmarkDeleted()
                }
        })
    }
    
    public static func bookmark(folderName: String, viewController: UIViewController) {
        var folderName = folderName
        if folderName == BookmarkFolder.UNCATEGORIZED {
            folderName = ""
        }
        var parameters: Parameters = ["folder": folderName]
        if let questionViewController = viewController as? ReviewQuestionsViewController {
            parameters["object_id"] = questionViewController.attemptItem.id
            parameters["content_type"] = ["model": "userselectedanswer", "app_label": "exams"]
        } else {
            var content: Content
            if let htmlViewController = viewController as? HtmlContentViewController {
                content = htmlViewController.content
            } else {
                let attachmentViewController = viewController as! AttachmentDetailViewController
                content = attachmentViewController.content
            }
            parameters["object_id"] = content.id
            parameters["content_type"] = ["model": "chaptercontent", "app_label": "courses"]
        }
        TPApiClient.request(
            type: Bookmark.self,
            endpointProvider: TPEndpointProvider(.post, urlPath: TPEndpoint.bookmarks.urlPath),
            parameters: parameters,
            completion: {
                bookmark, error in
                if let error = error {
                    debugPrint(error.message ?? "No error")
                    debugPrint(error.kind)
                    BookmarkHelper.displayBookmarkButton(in: viewController)
                    var (_, _, description) = error.getDisplayInfo()
                    if error.isClientError() {
                        description = Strings.INVALID_FOLDER_NAME
                    }
                    TTGSnackbar(message: description, duration: .middle).show()
                    return
                }
                
                BookmarkHelper.updateBookmark(with: bookmark!.id, in: viewController)
        })
    }
    
    public static func update(folderName: String, in bookmarkId: Int,
                              on viewController: UIViewController, newFolder: Bool = false) {
        
        var folderName = folderName
        if folderName == BookmarkFolder.UNCATEGORIZED {
            folderName = ""
        }
        let parameters: Parameters = ["folder": folderName]
        let urlPath = TPEndpointProvider.getBookmarkPath(bookmarkId: bookmarkId)
        TPApiClient.request(
            type: Bookmark.self,
            endpointProvider: TPEndpointProvider(.put, urlPath: urlPath),
            parameters: parameters,
            completion: {
                bookmark, error in
                if let error = error {
                    debugPrint(error.message ?? "No error")
                    debugPrint(error.kind)
                    BookmarkHelper.displayMoveButton(in: viewController)
                    var (_, _, description) = error.getDisplayInfo()
                    if error.isClientError() {
                        description = Strings.INVALID_FOLDER_NAME
                    }
                    TTGSnackbar(message: description, duration: .middle).show()
                    return
                }
                
                BookmarkHelper.displayMoveButton(in: viewController)
                TTGSnackbar(message: Strings.BOOKMARK_MOVED_SUCCESSFULLY, duration: .middle).show()
                let navigationViewController = viewController.presentingViewController?
                    .presentedViewController as! UINavigationController
                
                let slidingViewController = navigationViewController.viewControllers.first
                    as! BookmarksSlidingViewController
                
                slidingViewController.onBookmarkFolderChanged(folderName: bookmark!.folder)
                if newFolder {
                    var folderAlreadyExists = false
                    for folder in slidingViewController.folders {
                        if folder.name == bookmark!.folder! {
                            folderAlreadyExists = true
                            break
                        }
                    }
                    if !folderAlreadyExists {
                        let bookmarkFolder = BookmarkFolder()
                        bookmarkFolder.id = bookmark!.folderId
                        bookmarkFolder.name = bookmark!.folder!
                        bookmarkFolder.bookmarksCount = 1
                        slidingViewController.folders.append(bookmarkFolder)
                        slidingViewController.foldersDropDown.addItem(folderName: bookmark!.folder!)
                    }
                }
        })
    }
}
