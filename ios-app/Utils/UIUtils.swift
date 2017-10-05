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
    
    static func showSimpleAlert(title: String? = nil,
                                message: String? = nil,
                                viewController: UIViewController,
                                cancelable: Bool = false,
                                cancelHandler: Selector? = nil,
                                completion: ((UIAlertAction) -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Strings.OK, style: UIAlertActionStyle.cancel,
                                      handler: completion))
        
        viewController.present(alert, animated: true, completion: {
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(
                UITapGestureRecognizer(target: viewController, action: cancelHandler))
        })
        
    }
    
    static func setButtonDropShadow(_ button: UIButton) {
        button.layer.shadowColor = UIColor.lightGray.cgColor
        button.layer.shadowOffset = CGSize(width:0, height: 2)
        button.layer.shadowOpacity = 0.9
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
    
}
