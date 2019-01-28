//
//  BookmarksTableViewController.swift
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

class BookmarksTableViewController: BasePagedTableViewController<BookmarksListResponse, Bookmark> {
    
    var parentviewController: BookmarksSlidingViewController!
    var pageViewController: BookmarksDetailPageViewController!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(pager: BookmarksPager(), coder: aDecoder)
    }
    
    override func viewDidLoad() {
        pageViewController = parentviewController.pageViewController
        useInterfaceBuilderSeperatorInset = true
        super.viewDidLoad()
        emptyView.emptyViewTitle.font = UIFont(name: emptyView.emptyViewTitle.font.fontName,
                                               size: 20)
        tableView.delegate = self
    }
    
    // MARK: - Table view data source
    override func tableViewCell(cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.BOOKMARKS_TABLE_VIEW_CELL, for: indexPath)
            as! BookmarksTableViewCell
        
        cell.initCell(position: indexPath.row, viewController: self)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        pageViewController.gotoBookmark(position: indexPath.row)
    }
    
    override func loadItems() {
        if loadingItems {
            return
        }
        if parentviewController.folders.isEmpty {
            parentviewController.loadFolders()
        }
        pager.clearValues()
        super.loadItems()
    }
    
    override func onLoadFinished(items: [Bookmark]) {
        self.items.append(contentsOf: items)
        super.onLoadFinished(items: self.items)
        pageViewController.updateBookmarks(self.items)
    }
    
    func removeBookmark(at index: Int) {
        items.remove(at: index)
        super.onLoadFinished(items: items)
    }
    
    override func refreshWithProgress() {
        items = []
        tableView.reloadData()
        pageViewController.updateBookmarks(items)
        super.refreshWithProgress()
    }
    
    override func handleError(_ error: TPError) {
        if !tableView.tableFooterView!.isHidden {
            tableView.tableFooterView!.isHidden = true
        }
        let (image, title, description) = error.getDisplayInfo()
        if parentviewController.isRightOpen()
            && pageViewController.pageViewController.view.isHidden {
            
            pageViewController.showErrorEmptyView(image: image, title: title,
                                                  description: description)
            return
        }
        super.handleError(error)
    }
    
    func setCurrentItem(position: Int) {
        if position == 0 && loadingItems  {
            return
        }
        tableView.selectRow(at: IndexPath(row: position, section: 0),
                            animated: false,
                            scrollPosition: .middle)
    }
    
    override func setEmptyText() {
        emptyView.setValues(
            image: #imageLiteral(resourceName: "bookmark_folder_flat_icon"),
            title: Strings.NO_BOOKMARKS,
            description: Strings.NO_BOOKMARKS_DESCRIPTION
        )
    }
    
    @IBAction func back() {
        dismiss(animated: true, completion: nil)
    }
    
}

extension BookmarksTableViewController: SlidingMenuDelegate {
    
    func dismissViewController() {
        back()
    }
}
