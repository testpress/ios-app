//
//  UIButton.swift
//  ios-app
//
//  Created by Karthik on 26/05/20.
//  Copyright © 2020 Testpress. All rights reserved.
//

import UIKit

extension UIButton{
    func addTextSpacing(spacing: CGFloat){
        let attributedString = NSMutableAttributedString(string: (self.titleLabel?.text!)!)
        attributedString.addAttribute(NSAttributedString.Key.kern, value: spacing, range: NSRange(location: 0, length: (self.titleLabel?.text!.characters.count)!))
        self.setAttributedTitle(attributedString, for: .normal)
    }
}
