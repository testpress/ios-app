//
//  Misc.swift
//  ios-app
//
//  Created by Testpress on 10/10/24.
//  Copyright © 2024 Testpress. All rights reserved.
//

import Foundation
import CourseKit
import Alamofire
import UIKit
import FBSDKLoginKit

class UserHelper {
    static func logout() {
        let fcmToken = UserDefaults.standard.string(forKey: Constants.FCM_TOKEN)
        let deviceToken = UserDefaults.standard.string(forKey: Constants.DEVICE_TOKEN)
        
        if (fcmToken != nil && deviceToken != nil ) {
            let parameters: Parameters = [
                "device_id": deviceToken!,
                "registration_id": fcmToken!,
                "platform": "ios"
            ]
            
            TPApiClient.apiCall(endpointProvider: TPEndpointProvider(.unRegisterDevice), parameters: parameters,
                                completion: { _, _ in})
        }
        UIApplication.shared.unregisterForRemoteNotifications()
        
        TestpressCourse.shared.clearData()
        TPApiClient.apiCall(endpointProvider: TPEndpointProvider(.logout), completion: {_,_ in})
        // Logout on Facebook
        LoginManager().logOut()
        KeychainTokenItem.clearKeychainItems()
    }
    
    static func showProfileDetails(_ viewController: UIViewController) {
        let storyboard = UIStoryboard(name: Constants.MAIN_STORYBOARD, bundle: nil)
        let profileViewController = storyboard.instantiateViewController(withIdentifier:
                                                                            Constants.PROFILE_VIEW_CONTROLLER) as! ProfileViewController
        
        viewController.present(profileViewController, animated: true)
    }
    
    static func getLoginOrTabViewController() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var viewController: UIViewController
        if (KeychainTokenItem.isExist()) {
            viewController = storyboard.instantiateViewController(withIdentifier:
                                                                    Constants.TAB_VIEW_CONTROLLER)
        } else {
            viewController = storyboard.instantiateViewController(withIdentifier:
                                                                    Constants.LOGIN_VIEW_CONTROLLER) as! LoginViewController
        }
        return viewController
    }
}

func isUserLoggedIn() -> Bool {
    return KeychainTokenItem.isExist()
}


