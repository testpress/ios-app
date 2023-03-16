//
//  DashboardSectionHeaderCell.swift
//  ios-app
//
//  Created by Karthik on 29/04/21.
//  Copyright © 2021 Testpress. All rights reserved.
//

import UIKit

class DashboardSectionHeaderCell: UICollectionViewCell {
    @IBOutlet weak var title: UILabel!
    
    func setTitle(titleText: String, icon: UIImage) {
        title.addLeading(image: icon, text: titleText)
    }

}


extension UILabel {
    func addLeading(image: UIImage, text:String) {
        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(x: 0, y: (self.font.capHeight - image.size.height).rounded() / 2, width: image.size.width, height: image.size.height)

        let attachmentString = NSAttributedString(attachment: attachment)
        let mutableAttributedString = NSMutableAttributedString()
        mutableAttributedString.append(attachmentString)
        
        let string = NSMutableAttributedString(string: "  " + text, attributes: [:])
        mutableAttributedString.append(string)
        self.attributedText = mutableAttributedString
    }
}
