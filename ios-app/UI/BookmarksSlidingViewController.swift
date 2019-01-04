//
//  BookmarksSlidingViewController.swift
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
import SlideMenuControllerSwift
import TTGSnackbar
import UIKit

class BookmarksSlidingViewController: SlideMenuController {
    
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    
    let loadingDialogController = UIUtils.initProgressDialog(message: Strings.PLEASE_WAIT + "\n\n")
    
    var slidingMenuDelegate: SlidingMenuDelegate!
    var pageViewController: BookmarksDetailPageViewController!
    var tableViewController: BookmarksTableViewController!
    var allBookmarks = true
    var folderPager: BookmarkFolderPager!
    var folders = [BookmarkFolder]()
    var foldersDropDown: BookmarkFoldersDropDown!
    
    override func awakeFromNib() {
        pageViewController = (storyboard?.instantiateViewController(withIdentifier:
            Constants.BOOKMARKS_DETAIL_PAGE_VIEW_CONTROLLER) as! BookmarksDetailPageViewController)
        
        pageViewController.parentviewController = self
        self.rightViewController = pageViewController
        
        tableViewController = (storyboard?.instantiateViewController(withIdentifier:
            Constants.BOOKMARKS_TABLE_VIEW_CONTROLLER) as! BookmarksTableViewController)
        
        tableViewController.parentviewController = self
        self.mainViewController = tableViewController
        slidingMenuDelegate = tableViewController
        
        SlideMenuOptions.contentViewScale = 1.0
        SlideMenuOptions.hideStatusBar = false
        SlideMenuOptions.panGesturesEnabled = false
        SlideMenuOptions.rightViewWidth = self.view.frame.size.width
        super.awakeFromNib()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if folders.isEmpty {
            folderPager = BookmarkFolderPager()
        }
    }
    
    func loadFolders() {
        folderPager.next(completion: {
            items, error in
            if let error = error {
                debugPrint(error.message ?? "No error")
                debugPrint(error.kind)
                let (_, _, description) = error.getDisplayInfo()
                TTGSnackbar(message: description, duration: .middle).show()
                return
            }
            
            if self.folderPager.hasMore {
                self.loadFolders()
            } else {
                self.folders = Array(items!.values)
                self.onLoadedFolders()
            }
        })
    }
    
    func onLoadedFolders() {
        foldersDropDown = BookmarkFoldersDropDown(self)
        foldersDropDown.dropDown.selectionAction = { (index: Int, folderName: String) in
            self.setCurrentFolder(index: index, folderName: folderName)
        }
        if !folders.isEmpty {
            foldersDropDown.titleButton.isHidden = false
        } else {
            navigationItem.titleView = nil
        }
    }
    
    func setCurrentFolder(index: Int, folderName: String) {
        if foldersDropDown.selectedItemIndex == index {
            return
        }
        foldersDropDown.selectedItemIndex = index
        foldersDropDown.reloadAllComponents()
        foldersDropDown.titleButton.setTitle(folderName, for: .normal)
        let bookmarksPager = tableViewController.pager as! BookmarksPager
        if index == 0 {
            bookmarksPager.folder = nil
        } else if index <= folders.count {
            bookmarksPager.folder = folderName
        } else {
            bookmarksPager.folder = "null"
        }
        tableViewController.refreshWithProgress()
    }
    
    func onBookmarkFolderChanged(folderName: String?) {
        var position = pageViewController.getCurrentIndex()
        if foldersDropDown.selectedItemIndex == 0 {
            let bookmark = pageViewController.bookmarksDataSource.bookmarks[position]
            for folder in folders {
                if folderName == folder.name {
                    folder.bookmarksCount += 1
                }
                if bookmark.folder == folder.name {
                    folder.bookmarksCount -= 1
                }
            }
            bookmark.folder = folderName
            foldersDropDown.reloadAllComponents()
        } else {
            let previousBookmarksCount = pageViewController.bookmarksDataSource.bookmarks.count
            tableViewController.removeBookmark(at: position)
            pageViewController.bookmarksDataSource.bookmarks.remove(at: position)
            if previousBookmarksCount == position + 1 {
                position -= 1
            }
            pageViewController.onDataSetChanged(currentPosition: position)
            if foldersDropDown.selectedItemIndex <= folders.count {
                folders[foldersDropDown.selectedItemIndex - 1].bookmarksCount -= 1
            }
            for folder in folders {
                if folderName == folder.name {
                    folder.bookmarksCount += 1
                    break
                }
            }
            foldersDropDown.reloadAllComponents()
        }
    }
    
    func onBookmarkDeleted() {
        var position = pageViewController.getCurrentIndex()
        let previousBookmarksCount = pageViewController.bookmarksDataSource.bookmarks.count
        tableViewController.removeBookmark(at: position)
        let bookmark = pageViewController.bookmarksDataSource.bookmarks.remove(at: position)
        if previousBookmarksCount == position + 1 {
            position -= 1
        }
        pageViewController.onDataSetChanged(currentPosition: position)
        if bookmark.folder != nil {
            for folder in folders {
                if bookmark.folder == folder.name {
                    folder.bookmarksCount -= 1
                    foldersDropDown.reloadAllComponents()
                    break
                }
            }
        }
    }
    
    func updateFolder(index: Int, folderId: Int, folderName: String) {
        present(loadingDialogController, animated: false, completion: nil)
        let parameters: Parameters = ["name": folderName]
        let urlPath = TPEndpointProvider.getBookmarkFolderPath(folderId: folderId)
        TPApiClient.request(
            type: BookmarkFolder.self,
            endpointProvider: TPEndpointProvider(.put, urlPath: urlPath),
            parameters: parameters,
            completion: {
                folder, error in
                if let error = error {
                    debugPrint(error.message ?? "No error")
                    debugPrint(error.kind)
                    self.loadingDialogController.dismiss(animated: false, completion: nil)
                    var (_, _, description) = error.getDisplayInfo()
                    if error.isClientError() {
                        description = Strings.INVALID_FOLDER_NAME
                    }
                    TTGSnackbar(message: description, duration: .middle).show()
                    return
                }
                
                self.loadingDialogController.dismiss(animated: false, completion: {
                    self.foldersDropDown.updateItem(at: index, with: folder!.name)
                    self.foldersDropDown.reloadAllComponents()
                    TTGSnackbar(message: Strings.FOLDER_UPDATED_SUCCESSFULLY, duration: .middle)
                        .show()
                })
        })
    }
    
    func deleteFolder(folderId: Int, deletedPosition: Int) {
        present(loadingDialogController, animated: false, completion: nil)
        let urlPath = TPEndpointProvider.getBookmarkFolderPath(folderId: folderId)
        TPApiClient.apiCall(
            endpointProvider: TPEndpointProvider(.delete, urlPath: urlPath),
            completion: {
                void, error in
                if let error = error {
                    debugPrint(error.message ?? "No error")
                    debugPrint(error.kind)
                    self.loadingDialogController.dismiss(animated: false, completion: nil)
                    let (_, _, description) = error.getDisplayInfo()
                    TTGSnackbar(message: description, duration: .middle).show()
                    return
                }
                
                self.loadingDialogController.dismiss(animated: false, completion: {
                    let currentFolderPosition = self.foldersDropDown.selectedItemIndex
                    self.foldersDropDown.deleteItem(at: deletedPosition)
                    if currentFolderPosition == 0 {
                        self.tableViewController.refreshWithProgress()
                        self.foldersDropDown.dropDown.hide()
                        self.foldersDropDown.dropDown.selectRow(at: 0)
                    } else if currentFolderPosition == deletedPosition {
                        self.setCurrentFolder(index: 0, folderName: Strings.ALL_BOOKMARKS)
                        self.foldersDropDown.dropDown.hide()
                    } else {
                        if deletedPosition < currentFolderPosition {
                            self.foldersDropDown.selectedItemIndex -= 1
                            self.foldersDropDown.reloadAllComponents()
                        }
                        self.foldersDropDown.dropDown
                            .selectRow(at: self.foldersDropDown.selectedItemIndex)
                    }
                    TTGSnackbar(message: Strings.FOLDER_DELETED_SUCCESSFULLY, duration: .middle)
                        .show()
                })
        })
    }
    
    @objc func closeAlert() {
        dismiss(animated: true)
    }
    
    @IBAction func onPressBackButton() {
        if isRightOpen() {
            slideMenuController()?.closeRight()
            foldersDropDown.titleButton.isHidden = false
            if pageViewController.getCurrentIndex() != -1 {
                let indexPath = IndexPath(row: pageViewController.getCurrentIndex(), section: 0)
                tableViewController.tableView
                    .selectRow(at: indexPath, animated: false, scrollPosition: .middle)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.tableViewController.tableView.deselectRow(at: indexPath, animated: true)
                }
            }
        } else {
            slidingMenuDelegate.dismissViewController()
        }
    }
    
}
