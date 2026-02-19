//
//  UnauthorizedDeviceViewController.swift
//  ios-app
//
//  Created by Testpress on 07/10/24.
//  Copyright © 2024 Testpress. All rights reserved.
//

import UIKit
import CourseKit

class UnauthorizedDeviceViewController: UIViewController {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    static var overlayWindow: UIWindow?
    var errorMessage: String?
    
    static func show(errorMessage: String?) {
        guard overlayWindow == nil else { return }

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.windowLevel = .alert + 1
        window.backgroundColor = .clear

        let storyboard = UIStoryboard(name: Constants.MAIN_STORYBOARD, bundle: nil)
        let unauthorizedVC = storyboard.instantiateViewController(withIdentifier:
                                    Constants.UNAUTHORIZED_DEVICE_VIEW_CONTROLLER) as! UnauthorizedDeviceViewController
        unauthorizedVC.errorMessage = errorMessage

        window.rootViewController = unauthorizedVC
        overlayWindow = window
        window.makeKeyAndVisible()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let errorMessage = errorMessage {
            descriptionLabel.text = errorMessage
        }
    }
    
    @IBAction func onActionTapped(_ sender: UIButton) {
        UnauthorizedDeviceViewController.overlayWindow?.isHidden = true
        UnauthorizedDeviceViewController.overlayWindow = nil
        UserHelper.logout()
        
        if let window = (UIApplication.shared.delegate as? AppDelegate)?.window {
            window.rootViewController = UserHelper.getLoginOrTabViewController()
            window.makeKeyAndVisible()
        }
    }
}
