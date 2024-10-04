//
//  BookmarkFoldersDropDown.swift
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
import CourseKit

class BookmarkFoldersDropDown {
    
    var titleButton: UIButton!
    var dropDown: DropDown!
    var folderNames = [String]()
    var selectedItemIndex: Int = 0
    var viewController: BookmarksSlidingViewController!
    
    init(_ viewController: BookmarksSlidingViewController) {
        self.viewController = viewController
        titleButton = UIButton(type: .system)
        let image = #imageLiteral(resourceName: "ic_arrow_drop_down")
        titleButton.setImage(image, for: .normal)
        titleButton.tintColor = .white
        titleButton.setTitle(Strings.ALL_BOOKMARKS, for: .normal)
        titleButton.setTitleColor(.white, for: .normal)
        titleButton.addTarget(self, action: #selector(self.onClickDropDown), for: .touchUpInside)
        titleButton.sizeToFit()
        viewController.navigationItem.titleView = titleButton
        
        dropDown = DropDown()
        dropDown.anchorView = viewController.navigationItem.titleView
        dropDown.width = viewController.view.frame.width
        dropDown.bottomOffset = CGPoint(x: 0, y: dropDown.anchorView!.plainView.bounds.height + 5)
        dropDown.backgroundColor = UIColor.white
        dropDown.selectionBackgroundColor = Colors.getRGB(Colors.GRAY_LIGHT, alpha: 0.4)
        dropDown.offsetFromWindowBottom = 30
        folderNames.append(Strings.ALL_BOOKMARKS)
        for folder in viewController.folders {
            folderNames.append(folder.name)
        }
        folderNames.append(BookmarkFolder.UNCATEGORIZED)
        dropDown.dataSource = folderNames
        dropDown.cellNib = UINib(nibName: "BookmarkFoldersDropDownCell", bundle: nil)
        dropDown.selectRow(at: 0)
        dropDown.customCellConfiguration = {
            (index: Index, item: String, cell: DropDownCell) -> Void in
            let cell = cell as! BookmarkFoldersDropDownCell
            let selected = index == self.selectedItemIndex
            cell.initCell(index: index, folderName: item, selected: selected,
                          viewController: viewController)
        }
    }
    
    func updateItem(at index: Int, with folderName: String) {
        viewController.folders[index - 1].name = folderName
        folderNames[index] = folderName
        dropDown.dataSource = folderNames
        if selectedItemIndex == index {
            titleButton.setTitle(folderName, for: .normal)
        }
    }
    
    func addItem(folderName: String) {
        if (selectedItemIndex + 1) == folderNames.count {
            selectedItemIndex += 1
        }
        folderNames.insert(folderName, at: folderNames.count - 1)
        dropDown.dataSource = folderNames
        dropDown.selectRow(at: selectedItemIndex)
        if folderNames.count == 3 {
            viewController.navigationItem.titleView = titleButton
        }
    }
    
    func deleteItem(at index: Int) {
        viewController.folders.remove(at: index - 1)
        folderNames.remove(at: index)
        dropDown.dataSource = folderNames
    }
    
    func reloadAllComponents() {
        dropDown.reloadAllComponents()
        dropDown.selectRow(at: selectedItemIndex)
    }
    
    @objc func onClickDropDown() {
        dropDown.show()
    }
}
