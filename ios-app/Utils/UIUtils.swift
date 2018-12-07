//
//  UIUtils.swift
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

public class UIUtils {

    static func initActivityIndicator(parentView: UIView) -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(frame: parentView.frame)
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.color = Colors.getRGB(Colors.PRIMARY)
        activityIndicator.backgroundColor = UIColor.white
        activityIndicator.center = parentView.center
        parentView.addSubview(activityIndicator)
        parentView.bringSubview(toFront: activityIndicator)
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }
    
    static func initProgressDialog(message: String) -> UIAlertController {
        let alertController = UIAlertController(title: nil, message: message,
                                                preferredStyle: .alert)
        
        let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        
        spinnerIndicator.center = CGPoint(x: 135.0, y: 65.5)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        
        alertController.view.addSubview(spinnerIndicator)
        return alertController
    }
    
    @discardableResult
    static func showSimpleAlert(title: String? = nil,
                                message: String? = nil,
                                viewController: UIViewController,
                                positiveButtonText: String = Strings.OK,
                                positiveButtonStyle: UIAlertActionStyle = .default,
                                negativeButtonText: String? = nil,
                                cancelable: Bool = false,
                                cancelHandler: Selector? = nil,
                                completion: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if negativeButtonText != nil {
            alert.addAction(UIAlertAction(title: negativeButtonText!,
                                          style: UIAlertActionStyle.default))
        }
        alert.addAction(UIAlertAction(title: positiveButtonText, style: positiveButtonStyle,
                                      handler: completion))
        
        viewController.present(alert, animated: true, completion: {
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(
                UITapGestureRecognizer(target: viewController, action: cancelHandler))
        })
        return alert
    }
    
    static func setButtonDropShadow(_ view: UIView) {
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOffset = CGSize(width:0, height: 2)
        view.layer.shadowOpacity = 0.9
    }
    
    // Add gradient shadow layer to the shadow container view
    static func updateBottomShadow(bottomShadowView: UIView, bottomGradient: CAGradientLayer) {
        bottomGradient.frame = bottomShadowView.bounds
        bottomGradient.colors = [UIColor.white.cgColor, UIColor.black.cgColor]
        bottomShadowView.layer.insertSublayer(bottomGradient, at: 0)
    }
    
    static func setTableViewSeperatorInset(_ tableView: UITableView, size: CGFloat) {
        tableView.preservesSuperviewLayoutMargins = false
        tableView.separatorInset = UIEdgeInsetsMake(0, size, 0, size);
        tableView.layoutMargins = UIEdgeInsets.zero;
    }
    
    static func getAppName() -> String {
        return Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? ""
    }
    
    static func getActionSheetStyle() -> UIAlertControllerStyle {
        return (UIDevice.current.userInterfaceIdiom == .phone) ? .actionSheet : .alert
    }
    
    static func isiPad() -> Bool {
        return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad
    }
    
    static func ellipsize(text: String, size: Int) -> String {
        if (text.count < size) {
            return text
        } else {
            let endIndex = text.index(text.startIndex, offsetBy: (size - 3))
            return String(text[text.startIndex...endIndex]) + "..."
        }
    }
    
    static func showProfileDetails(_ viewController: UIViewController) {
        let storyboard = UIStoryboard(name: Constants.MAIN_STORYBOARD, bundle: nil)
        let profileViewController = storyboard.instantiateViewController(withIdentifier:
            Constants.PROFILE_VIEW_CONTROLLER) as! ProfileViewController
        
        viewController.present(profileViewController, animated: true)
    }
    
    static func fetchInstituteSettings(
        completion: @escaping(InstituteSettings?, TPError?) -> Void) {
        TPApiClient.request(
            type: InstituteSettings.self,
            endpointProvider: TPEndpointProvider(.instituteSettings),
            completion: {
                instituteSettings, error in
                if let error = error {
                    debugPrint(error.message ?? "No error")
                    debugPrint(error.kind)
                } else {
                    instituteSettings!.baseUrl = Constants.BASE_URL
                    DBManager<InstituteSettings>().addData(objects: [instituteSettings!])
                }
                completion(instituteSettings,error)
        })
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
