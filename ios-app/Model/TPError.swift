//
//  TPError.swift
//  ios-app
//
//  Copyright © 2017 Testpress. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit
import Alamofire

public class TPError: Error {
    
    /// Identifies the event kind which triggered TestpressError.
    public enum Kind {
        case
        /// No internet, cannot communicate to the server.
        network,
        /// HTTP status code 403 was received from the server.
        unauthenticated,
        /// A non-200 HTTP status code was received from the server.
        http,
        custom,
        /// All other errors
        unexpected
    }
    
    /// HTTP status code for error.
    public let statusCode: Int
    
    /// Human readable message which corresponds to the error.
    public var message: String?
    
    public var response: HTTPURLResponse?
    
    public var error_detail: String?
    public var error_code: String?
    
    /// Identifies the event kind which triggered this error
    public var kind: Kind
    
    public init(message: String? = nil, response: HTTPURLResponse? = nil, kind: Kind) {
        self.statusCode = response?.statusCode ?? -1
        self.message = message
        self.response = response
        self.kind = kind

        if let error_detail = self.getErrorBodyAs(type: ApiError.self) {
            self.kind = Kind.custom
            self.error_detail = error_detail.detail
            self.error_code = error_detail.error_code
        }
        
    }
    
    public func isNetworkError() -> Bool {
        return kind == .network;
    }
    
    public func isClientError() -> Bool {
        return statusCode >= 400 && statusCode < 500;
    }
    
    public func isServerError() -> Bool {
        return statusCode >= 500 && statusCode < 600;
    }
    
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
            if self.error_code == Constants.MULTIPLE_LOGIN_RESTRICTION_ERROR_CODE || self.error_code == Constants.MAX_LOGIN_LIMIT_EXCEEDED{
                var rootViewController = UIApplication.shared.keyWindow?.rootViewController
                if let navigationController = rootViewController as? UINavigationController {
                    rootViewController = navigationController.viewControllers.first
                }
                if let tabBarController = rootViewController as? UITabBarController {
                    rootViewController = tabBarController.selectedViewController
                }
                let alert = UIAlertController(title: Strings.LOADING_FAILED,
                                              message: self.error_detail,
                                              preferredStyle: UIUtils.getActionSheetStyle())
                alert.addAction(UIAlertAction(
                    title: Strings.OK,
                    style: UIAlertActionStyle.destructive,
                    handler: { action in
                        let storyboard = UIStoryboard(name: Constants.MAIN_STORYBOARD, bundle: nil)
                        let tabViewController = storyboard.instantiateViewController(
                            withIdentifier: Constants.LOGIN_ACTIVITY_VIEW_CONTROLLER)
                        rootViewController!.present(tabViewController, animated: true, completion: nil)
                }))
                alert.addAction(UIAlertAction(title: Strings.CANCEL, style: UIAlertActionStyle.cancel))
                rootViewController!.present(alert, animated: true)
            }
            return (Images.TestpressAlertWarning.image,
                    Strings.LOADING_FAILED,
                    self.error_detail ?? Strings.SOMETHIGN_WENT_WRONG)
        default:
            return (Images.TestpressAlertWarning.image,
                    Strings.LOADING_FAILED,
                    Strings.SOMETHIGN_WENT_WRONG)
        }
    }
    
    public func getErrorBodyAs<T: TestpressModel>(type: T.Type) -> T? {
        return TPModelMapper<T>().mapFromJSON(json: message!)
    }
    
}


