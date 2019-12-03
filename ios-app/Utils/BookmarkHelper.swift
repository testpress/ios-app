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
    weak var delegate: BookmarkDelegate?
    
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
        delegate?.onClickMoveButton()
        showFoldersList(bookmark: bookmark)
    }
    
    func onClickRemoveButton(bookmark: Bookmark) {
        if slidingViewController == nil {
            let navigationViewController = viewController.presentingViewController?
                .presentedViewController as! UINavigationController
            
            slidingViewController = (navigationViewController.viewControllers.first
                as! BookmarksSlidingViewController)
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
        delegate?.removeBookmark()
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
        delegate?.onClickBookmarkButton()
        if bookmarkId != nil {
            deleteBookmark(bookmarkId: bookmarkId!)
        } else {
            showFoldersList()
        }
    }
    
    func updateBookmark(with bookmarkId: Int?) {
        delegate?.updateBookmark(bookmarkId: bookmarkId)
    }

    func displayBookmarkButton() {
        delegate?.displayBookmarkButton()
    }
    
    func displayMoveButton() {
        delegate?.displayMoveButton()
    }
    
    func displayRemoveButton() {
        delegate?.displayRemoveButton()
    }
    
    func showFoldersList(bookmark: Bookmark? = nil) {
        let storyboard = UIStoryboard(name: Constants.BOOKMARKS_STORYBOARD, bundle: nil)
        let navigationController = storyboard.instantiateViewController(withIdentifier:
            Constants.BOOKMARK_FOLDER_NAVIGATION_CONTROLLER) as! UINavigationController
        
        let foldersTableViewController = navigationController.viewControllers.first
            as! BookmarkFolderTableViewController
        
        foldersTableViewController.bookmark = bookmark
        foldersTableViewController.bookmarkDelegate = delegate
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
                        self.displayBookmarkButton()
                    } else {
                        self.displayRemoveButton()
                    }
                    let (_, _, description) = error.getDisplayInfo()
                    TTGSnackbar(message: description, duration: .middle).show()
                    return
                }
                
                if self.slidingViewController == nil {
                    self.updateBookmark(with: nil)
                } else {
                    TTGSnackbar(
                        message: Strings.BOOKMARK_DELETED_SUCCESSFULLY,
                        duration: .middle
                    ).show()
                    self.slidingViewController.onBookmarkDeleted()
                }
        })
    }
    
    func bookmark(folderName: String) {
        var folderName = folderName
        if folderName == BookmarkFolder.UNCATEGORIZED {
            folderName = ""
        }
        var parameters: Parameters = delegate?.getBookMarkParams() ?? Parameters()
        parameters["folder"] = folderName
        
        TPApiClient.request(
            type: Bookmark.self,
            endpointProvider: TPEndpointProvider(.post, urlPath: TPEndpoint.bookmarks.urlPath),
            parameters: parameters,
            completion: {
                bookmark, error in
                if let error = error {
                    debugPrint(error.message ?? "No error")
                    debugPrint(error.kind)
                    self.displayBookmarkButton()
                    var (_, _, description) = error.getDisplayInfo()
                    if error.isClientError() {
                        description = Strings.INVALID_FOLDER_NAME
                    }
                    TTGSnackbar(message: description, duration: .middle).show()
                    return
                }
                
                self.updateBookmark(with: bookmark!.id)
        })
    }
    
    func update(folderName: String, in bookmarkId: Int,
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
                    self.displayMoveButton()
                    var (_, _, description) = error.getDisplayInfo()
                    if error.isClientError() {
                        description = Strings.INVALID_FOLDER_NAME
                    }
                    TTGSnackbar(message: description, duration: .middle).show()
                    return
                }
                
                self.displayMoveButton()
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


protocol BookmarkDelegate: AnyObject {
    func onClickMoveButton()
    
    func removeBookmark()
        
    func displayRemoveButton()
    
    func onClickBookmarkButton()
    
    func getBookMarkParams() -> Parameters?
    
    func updateBookmark(bookmarkId: Int?)
    
    func displayBookmarkButton()
    
    func displayMoveButton()
    
}
