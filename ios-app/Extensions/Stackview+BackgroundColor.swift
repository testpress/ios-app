//
//  Stackview+BackgroundColor.swift
//  ios-app
//
//  Created by Karthik raja on 9/9/19.
//  Copyright © 2019 Testpress. All rights reserved.
//
import UIKit

extension UIStackView {
    
    func addBackground(color: UIColor) {
        let subview = UIView(frame: bounds)
        subview.backgroundColor = color
        subview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subview, at: 0)
    }
    
}
