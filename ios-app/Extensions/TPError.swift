//
//  TPError.swift
//  ios-app
//
//  Created by Testpress on 04/10/24.
//  Copyright © 2024 Testpress. All rights reserved.
//

import Foundation
import CourseKit
import UIKit

extension TPError {
    public func getDisplayInfo() -> (image: UIImage, title: String, description: String) {
        switch (kind) {
        case .network:
            return (Images.TestpressNoWifi.image,
                    Strings.NETWORK_ERROR,
                    Strings.PLEASE_CHECK_INTERNET_CONNECTION)
            
        case .unauthenticated:
            return (Images.TestpressAlertWarning.image,
                    Strings.AUTHENTICATION_FAILED,
                    Strings.PLEASE_LOGIN)
        case .custom:
            return (Images.TestpressAlertWarning.image,
                    Strings.LOADING_FAILED,
                    self.error_detail!)
        default:
            return (Images.TestpressAlertWarning.image,
                    Strings.LOADING_FAILED,
                    Strings.SOMETHIGN_WENT_WRONG)
        }
    }
}
