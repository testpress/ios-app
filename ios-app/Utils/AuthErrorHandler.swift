//
//  AuthErrorHandler.swift
//  ios-app
//
//  Created by Testpress on 07/10/24.
//  Copyright © 2024 Testpress. All rights reserved.
//

import Foundation
import CourseKit
import UIKit

class AuthErrorHandler: AuthErrorHandlingDelegate {
    func handleUnauthenticatedError() {
        UserHelper.logout()
        presentLoginViewController()
    }

    func handleMaxLoginLimitError() {
        let instituteSettings = DBManager<InstituteSettings>().getResultsFromDB().first
        var message = Strings.MAX_LOGIN_EXCEEDED_ERROR_MESSAGE

        if let coolOffTime = instituteSettings?.cooloffTime, !coolOffTime.isEmpty {
            message += Strings.ACCOUNT_UNLOCK_INFO + "\(coolOffTime) hours"
        }

        UIUtils.showSimpleAlert(
            title: Strings.ACCOUNT_LOCKED,
            message: message,
            viewController: getRootViewController()!,
            cancelable: true
        )
    }

    func handleMultipleLoginRestrictionError(error: TPError) {
        guard let rootViewController = getRootViewController() else { return }
        
        let alert = UIAlertController(
            title: Strings.LOADING_FAILED,
            message: error.error_detail,
            preferredStyle: UIUtils.getActionSheetStyle()
        )
        
        alert.addAction(UIAlertAction(title: Strings.OK, style: .destructive) { _ in
            self.presentLoginViewController(from: rootViewController)
        })
        
        alert.addAction(UIAlertAction(title: Strings.CANCEL, style: .cancel, handler: nil))
        
        rootViewController.present(alert, animated: true, completion: nil)
    }
    
    private func presentLoginViewController(from viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            let storyboard = UIStoryboard(name: Constants.MAIN_STORYBOARD, bundle: nil)
            let loginActivityViewController = storyboard.instantiateViewController(withIdentifier:
                                        Constants.LOGIN_ACTIVITY_VIEW_CONTROLLER) as! LoginActivityViewController
            
            topController.present(loginActivityViewController, animated: true, completion: nil)
        }
    }
    
    private func getRootViewController() -> UIViewController? {
        guard var rootViewController = UIApplication.shared.keyWindow?.rootViewController else { return nil }
        
        if let navigationController = rootViewController as? UINavigationController {
            rootViewController = navigationController.viewControllers.first!
        } else if let tabBarController = rootViewController as? UITabBarController {
            rootViewController = tabBarController.selectedViewController!
        }
        
        return rootViewController
    }
}

