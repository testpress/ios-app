//
//  UIView.swift
//  ios-app
//
//  Created by Karthik raja on 12/6/19.
//  Copyright © 2019 Testpress. All rights reserved.
//

import UIKit


extension UIView {
    public func fitSizeOfContent() -> CGSize {
        let sumHeight = self.subviews.map({$0.frame.size.height}).reduce(0, {x, y in x + y})
        return CGSize(width: self.frame.width, height: sumHeight)
    }
    
    
    fileprivate struct AssociatedObjectKeys {
        static var tapGestureRecognizer = "MediaViewerAssociatedObjectKey_mediaViewer"
    }
    
    fileprivate typealias Action = (() -> Void)?
    
    fileprivate var tapGestureRecognizerAction: Action? {
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            let tapGestureRecognizerActionInstance = objc_getAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer) as? Action
            return tapGestureRecognizerActionInstance
        }
    }
    
    public func addTapGestureRecognizer(action: (() -> Void)?) {
        self.isUserInteractionEnabled = true
        self.tapGestureRecognizerAction = action
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc fileprivate func handleTapGesture(sender: UITapGestureRecognizer) {
        if let action = self.tapGestureRecognizerAction {
            action?()
        } else {
            print("no action")
        }
    }
    
    public class func fromNib<T: UIView>(_ name: String? = nil) -> T {
        let nibName = name ?? String(describing: T.self)
        return bundle.loadNibNamed(nibName, owner: nil, options: nil)![0] as! T
    }
    
}
