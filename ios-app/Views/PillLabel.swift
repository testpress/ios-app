//
//  PillLabel.swift
//  ios-app
//
//  Created by Karthik on 03/05/21.
//  Copyright © 2021 Testpress. All rights reserved.
//

import UIKit

/// A UILabel that looks like a pill! Set background color and text color to customize the appearance.
@IBDesignable class PillUILabel: UILabel {

    @IBInspectable var verticalPad: CGFloat = 0
    @IBInspectable var horizontalPad: CGFloat = 0

    func setup() {
        layer.cornerRadius = frame.height / 2
        clipsToBounds = true
        textAlignment = .center
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }

    override var intrinsicContentSize: CGSize {
        let superSize = super.intrinsicContentSize
        let newWidth = superSize.width + superSize.height + (2 * horizontalPad)
        let newHeight = superSize.height + (2 * verticalPad)
        let newSize = CGSize(width: newWidth, height: newHeight)
        return newSize
    }
}
