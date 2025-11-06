//
//  LockableSectionDropDownCell.swift
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

class LockableSectionDropDownCell: DropDownCell {
    
    @IBOutlet weak var currentStateImage: UIImageView!
    
    func initCell(index: Int, sectionName: String, selectedItem: Int) {
        optionLabel.text = sectionName
        if selectedItem == index {
            optionLabel.textColor = Colors.getRGB(Colors.BLACK_TEXT)
            currentStateImage.tintColor = Colors.getRGB(Colors.MATERIAL_GREEN2)
            currentStateImage.image = UIImage(named: "check_mark", in: TestpressCourse.bundle, compatibleWith: nil)
        } else {
            optionLabel.textColor = Colors.getRGB(Colors.GRAY_MEDIUM_DARK)
            currentStateImage.tintColor = Colors.getRGB(Colors.GRAY_MEDIUM_DARK)
            if selectedItem > index {
                currentStateImage.image = UIImage(named: "ic_lock_with_tick_18pt", in: TestpressCourse.bundle, compatibleWith: nil)
            } else {
                currentStateImage.image = UIImage(named: "ic_lock_outline_18pt", in: TestpressCourse.bundle, compatibleWith: nil)
            }
        }
        separatorInset = UIEdgeInsets.zero
    }
    
}
