//
//  UIViewController.swift
//  ios-app
//
//  Copyright © 2020 Testpress. All rights reserved.
//

import UIKit

extension UIViewController {
    public func setStatusBarColor() {
        if #available(iOS 13.0, *) {
                let app = UIApplication.shared
                let statusBarHeight: CGFloat = app.statusBarFrame.size.height
                let statusbarView = UIView()
                statusbarView.backgroundColor = TestpressCourse.shared.statusBarColor
                view.addSubview(statusbarView)
                statusbarView.translatesAutoresizingMaskIntoConstraints = false
                statusbarView.heightAnchor
            .constraint(equalToConstant: statusBarHeight).isActive = true
                statusbarView.widthAnchor
            .constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
                statusbarView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
                statusbarView.centerXAnchor.constraint(equalTo:   view.centerXAnchor).isActive = true
          } else {
              let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar")
                  as? UIView
              
              statusBar?.backgroundColor = TestpressCourse.shared.statusBarColor
        }
    }

    public func add(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    public func remove() {
        guard parent != nil else {
            return
        }

        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
    
    public func getCurrentOrientation() -> UIInterfaceOrientation {
        if #available(iOS 16.0, *) {
            if let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation {
                return orientation
            }
        } else {
            let deviceOrientation = UIDevice.current.orientation
            switch deviceOrientation {
            case .portrait:
                return .portrait
            case .portraitUpsideDown:
                return .portraitUpsideDown
            case .landscapeLeft:
                return .landscapeRight
            case .landscapeRight:
                return .landscapeLeft
            default:
                break
            }
        }
        
        return .unknown
    }
}
