//
//  PlainDropDown.swift
//  ios-app
//
//  Copyright © 2018 Testpress. All rights reserved.
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

class PlainDropDown {
    
    var titleButton: UIButton!
    var dropDown: DropDown!
    var items: [String] = []
    
    init(containerView: UIView) {
        titleButton = UIButton(type: .system)
        titleButton.setImage(#imageLiteral(resourceName: "ic_arrow_drop_down"), for: .normal)
        titleButton.tintColor = Colors.getRGB(Colors.BLACK_TEXT)
        titleButton.setTitleColor(Colors.getRGB(Colors.BLACK_TEXT), for: .normal)
        titleButton.addTarget(
            self,
            action: #selector(self.onClickDropDown),
            for: .touchUpInside
        )
        titleButton.frame = containerView.bounds
        titleButton.frame.size.height -= 1
        containerView.addSubview(titleButton)
        
        dropDown = DropDown()
        dropDown.anchorView = titleButton
        dropDown.backgroundColor = UIColor.white
        dropDown.selectionBackgroundColor = Colors.getRGB(Colors.BLUE, alpha: 0.1)
        dropDown.offsetFromWindowBottom = 30
        dropDown.separatorColor = Colors.getRGB(Colors.GRAY_LIGHT)
        dropDown.dataSource = items
        dropDown.customCellConfiguration = {
            (index: Index, item: String, cell: DropDownCell) -> Void in
            
            cell.optionLabel.textAlignment = .center
            cell.separatorInset = UIEdgeInsets.zero
        }
    }
    
    func addItems(items: [String]) {
        self.items = items
        dropDown.dataSource = self.items
    }
    
    func setCurrentItem(index: Int) {
        titleButton.setTitle(items[index], for: .normal)
        dropDown.clearSelection()
        dropDown.reloadAllComponents()
        dropDown.selectRow(at: Index(index))
    }
    
    @objc func onClickDropDown() {
        dropDown.show()
    }
}
