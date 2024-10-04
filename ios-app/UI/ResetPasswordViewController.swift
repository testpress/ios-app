//
//  ResetPasswordViewController.swift
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

import Alamofire
import UIKit
import CourseKit

class ResetPasswordViewController: BaseTextFieldViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var resetPasswordButton: UIButton!
    
    let alertController = UIUtils.initProgressDialog(message: Strings.PLEASE_WAIT + "\n\n")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStatusBarColor()

        
        UIUtils.setButtonDropShadow(resetPasswordButton)
        
        // Set firstTextField in super class to set the cursor & show the keyboard
        firstTextField = emailField
    }
    
    @IBAction func onResetPasswordButtonClick(_ sender: UIView) {
        if validate() {
            hideKeyboard()
            present(alertController, animated: false, completion: nil)
            TPApiClient.resetPassword(
                email: emailField.text!,
                completion: { error in
                    if let error = error {
                        debugPrint(error.message ?? "No error message found")
                        debugPrint(error.kind)
                        self.alertController.dismiss(animated: true, completion: nil)
                        if error.isClientError() {
                            let registrationError =
                                error.getErrorBodyAs(type: RegistrationError.self)
                            
                            if !(registrationError?.email.isEmpty)! {
                                self.setFieldError(textField: self.emailField,
                                                   errorMessage: (registrationError?.email[0])!)
                            }
                        } else {
                            let (_, title, description) = error.getDisplayInfo()
                            UIUtils.showSimpleAlert(
                                title: title,
                                message: description,
                                viewController: self,
                                cancelable: true,
                                cancelHandler: #selector(self.closeAlert(gesture:))
                            )
                        }
                        return
                    }

                    let viewController = self.storyboard?.instantiateViewController(withIdentifier:
                        Constants.SUCCESS_VIEW_CONTROLLER) as! SuccessViewController

                    viewController.initSuccessViewController(
                        successDescription: Strings.RESET_PASSWORD_MAIL_SENT,
                        actionButtonText: Strings.LOGIN,
                        backButtonClickHandler: {
                            self.presentingViewController?.dismiss(animated: true)
                        }
                    )
                    self.alertController.dismiss(animated: true, completion: nil)
                    self.present(viewController, animated: true)
                }
            )
        }
    }
    
    @IBAction func onTextChangeListener() {
        resetPasswordButton.isEnabled = emailField.hasText
    }
    
    func validate() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        if !emailTest.evaluate(with: emailField.text) {
            setFieldError(textField: emailField, errorMessage: Strings.ENTER_VALID_EMAIL)
            return false
        }
        return true
    }
    
    func setFieldError(textField: UITextField, errorMessage: String) {
        textField.text = ""
        textField.attributedPlaceholder = NSAttributedString(
            string: errorMessage,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.red]
        )
        textField.becomeFirstResponder()
    }
    
    @objc func closeAlert(gesture: UITapGestureRecognizer) {
        dismiss(animated: true)
    }
    
    @IBAction func back() {
        dismiss(animated: true, completion: nil)
    }
    
}
