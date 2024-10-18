//
//  BookmarkFoldersDropDownCell.swift
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

import DropDown
import UIKit

class BookmarkFoldersDropDownCell: DropDownCell {
    
    @IBOutlet weak var folderNameLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var checkMark: UIImageView!
    @IBOutlet weak var countLabel: UILabel!
    
    var index: Int!
    var folderName: String!
    var folder: BookmarkFolder!
    var viewController: BookmarksSlidingViewController! = nil
    
    func initCell(index: Int, folderName: String, selected: Bool,
                  viewController: BookmarksSlidingViewController) {
        
        self.index = index
        self.folderName = folderName
        self.viewController = viewController
        
        folderNameLabel.text = folderName
        if index == 0 || index == viewController.folders.count + 1 {
            countLabel.isHidden = true
            editButton.isHidden = true
        } else {
            folder = viewController.folders[index - 1]
            countLabel.text = String(folder.bookmarksCount)
            countLabel.isHidden = false
            editButton.isHidden = false
        }
        if selected {
            checkMark.image = UIImage(named: "check_mark", in: TestpressCourse.bundle, compatibleWith: nil)
        } else {
            checkMark.image = nil
        }
    }
    
    @IBAction func onClickEditFolder() {
        let alert = UIAlertController(title: Strings.RENAME_FOLDER, message: nil,
                                      preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = self.folderName
            textField.enablesReturnKeyAutomatically = true
            textField.returnKeyType = .send
            textField.delegate = self
        }
        let index: Int = self.index
        let folder: BookmarkFolder = self.folder
        alert.addAction(UIAlertAction(title: Strings.DELETE, style: .destructive, handler: {
            alert in
            UIUtils.showSimpleAlert(
                title: Strings.ARE_YOU_SURE,
                message: Strings.WANT_TO_DELETE_FOLDER,
                viewController: self.viewController,
                positiveButtonText: Strings.YES,
                positiveButtonStyle: .destructive,
                negativeButtonText: Strings.NO,
                cancelable: true,
                cancelHandler: #selector(self.viewController.closeAlert),
                completion: { action in
                    self.viewController.deleteFolder(folderId: folder.id, deletedPosition: index)
            })
        }))
        alert.addAction(UIAlertAction(
            title: Strings.UDPATE,
            style: .default,
            handler: { [weak alert] (_) in
                let folderName = alert!.textFields![0].text!.trim()
                if folderName == "" || folderName == folder.name {
                    return
                }
                self.viewController.updateFolder(index: index, folderId: folder.id,
                                                 folderName: folderName)
        }))
        viewController.present(alert, animated: true, completion: {
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(
                UITapGestureRecognizer(target: self,
                                       action: #selector(self.alertControllerBackgroundTapped))
            )
        })
    }
    
    @objc func alertControllerBackgroundTapped() {
        viewController.dismiss(animated: false)
    }
    
}

extension BookmarkFoldersDropDownCell: UITextFieldDelegate {
    
    @nonobjc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onClickEditFolder()
        return true
    }
}
