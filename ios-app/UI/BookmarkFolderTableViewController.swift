//
//  BookmarkFolderTableViewController.swift
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

class BookmarkFolderTableViewController:
    BasePagedTableViewController<BookmarksListResponse, BookmarkFolder>, UITextFieldDelegate {
    
    var bookmark: Bookmark!
    var sourceViewController: UIViewController!
    var bookmarkHelper: BookmarkHelper!
    var bookmarkDelegate: BookmarkDelegate?
    var selectedIndex: Int!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(pager: BookmarkFolderPager(), coder: aDecoder)
    }
    
    override func viewDidLoad() {
        useInterfaceBuilderSeperatorInset = true
        super.viewDidLoad()
        let folder = BookmarkFolder()
        folder.name = BookmarkFolder.UNCATEGORIZED
        (pager as! BookmarkFolderPager).resources[0] = folder
        tableView.delegate = self
        bookmarkHelper = BookmarkHelper(viewController: sourceViewController)
        bookmarkHelper.delegate = bookmarkDelegate
    }
    
    // MARK: - Table view data source
    override func tableViewCell(cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.BOOKMARK_FOLDER_TABLE_VIEW_CELL, for: indexPath)
            as! BookmarkFolderTableViewCell
        
        cell.initCell(position: indexPath.row, viewController: self)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let folderName = items[indexPath.row].name
        if bookmark == nil {
            bookmarkHelper.bookmark(folderName: folderName)
        } else if folderName != bookmark.folder {
            bookmarkHelper.update(folderName: folderName, in: bookmark.id, on: sourceViewController)
        } else {
            hideProgressBar()
        }
        dismiss(animated: true)
    }
    
    override func onLoadFinished(items: [BookmarkFolder]) {
        var items = items
        let uncategorizedFolder = BookmarkFolder()
        uncategorizedFolder.name = BookmarkFolder.UNCATEGORIZED
        items.append(uncategorizedFolder)
        if bookmark != nil {
            for (position, folder) in items.enumerated() {
                if (bookmark!.folder != nil && bookmark!.folder == folder.name) ||
                    (folder.name == BookmarkFolder.UNCATEGORIZED && bookmark!.folder == nil) {
                    
                    selectedIndex = position
                    break
                }
            }
        }
        super.onLoadFinished(items: items)
        if selectedIndex != nil {
            let indexPath = IndexPath(row: selectedIndex, section: 0)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }
    
    @IBAction func onClickAddNewFolder() {
        let alert = UIAlertController(title: Strings.ENTER_FOLDER_NAME, message: nil,
                                      preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.enablesReturnKeyAutomatically = true
            textField.returnKeyType = .send
            textField.delegate = self
        }
        alert.addAction(UIAlertAction(title: Strings.CANCEL, style: .cancel))
        alert.addAction(UIAlertAction(
            title: Strings.CREATE,
            style: .default,
            handler: { [weak alert] (_) in
                self.createNewFolder(textField: alert!.textFields![0])
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func createNewFolder(textField: UITextField) {
        let folderName = textField.text!.trim()
        if folderName == "" || (bookmark != nil && folderName == bookmark.folder) {
            return
        }
        if bookmark != nil {
            bookmarkHelper.update(folderName: folderName, in: bookmark.id,
                                  on: sourceViewController, newFolder: true)
        } else {
            bookmarkHelper.bookmark(folderName: folderName)
        }
        dismiss(animated: true)
    }
    
    override func setEmptyText() {
        emptyView.setValues(image: Images.LearnFlatIcon.image, title: Strings.NO_ITEMS_EXIST,
                            description: Strings.NO_CONTENT_DESCRIPTION)
    }
    
    @IBAction func goBack() {
        hideProgressBar()
        dismiss(animated: true)
    }
    
    func hideProgressBar() {
        if bookmark != nil {
            bookmarkHelper.displayMoveButton()
        } else {
            bookmarkHelper.displayBookmarkButton()
        }
    }
    
    @nonobjc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        createNewFolder(textField: textField)
        return true
    }
    
}
