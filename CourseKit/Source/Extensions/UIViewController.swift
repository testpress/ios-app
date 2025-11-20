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
            view.subviews.filter { $0.tag == 999999 }.forEach { $0.removeFromSuperview() }
            let statusbarView = UIView()
            statusbarView.backgroundColor = TestpressCourse.shared.statusBarColor
            statusbarView.tag = 999999
            view.addSubview(statusbarView)
            statusbarView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                    statusbarView.topAnchor.constraint(equalTo: view.topAnchor),
                    statusbarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    statusbarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    statusbarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
                ])
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
