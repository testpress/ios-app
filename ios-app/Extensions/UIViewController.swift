//
//  UIViewController.swift
//  ios-app
//
//  Copyright © 2020 Testpress. All rights reserved.
//

import UIKit


extension UIViewController {
    func setStatusBarColor() {
        if #available(iOS 13.0, *) {
                let app = UIApplication.shared
                let statusBarHeight: CGFloat = app.statusBarFrame.size.height
                let statusbarView = UIView()
                statusbarView.backgroundColor = Colors.getRGB(Colors.PRIMARY)
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
              
              statusBar?.backgroundColor = Colors.getRGB(Colors.PRIMARY)
        }
    }
}
