//
//  UILabel.swift
//  CourseKit
//
//  Created by Testpress on 11/10/24.
//  Copyright © 2024 Testpress. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    public func addLeading(image: UIImage, text:String) {
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
