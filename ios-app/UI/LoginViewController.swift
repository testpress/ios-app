//
//  ViewController.swift
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
import FBSDKCoreKit
import FBSDKLoginKit
import UIKit

class LoginViewController: BaseTextFieldViewController {

    // MARK: Properties
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var navigationbarItem: UINavigationItem!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpLayout: UIStackView!
    @IBOutlet weak var socialLoginLayout: UIStackView!
    @IBOutlet weak var facebookButtonLayout: UIView!
        
    let alertController = UIUtils.initProgressDialog(message: Strings.PLEASE_WAIT + "\n\n")
    var instituteSettings: InstituteSettings!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStatusBarColor()
        
        navigationbarItem.title = UIUtils.getAppName()
        UIUtils.setButtonDropShadow(loginButton)
        
        instituteSettings = DBManager<InstituteSettings>().getResultsFromDB()[0]
        signUpLayout.isHidden = true
        socialLoginLayout.isHidden = true

        if(instituteSettings.allowSignup) {
            signUpLayout.isHidden = false
        }


        let fbLoginButton = FBLoginButton()

        
        fbLoginButton.center.x = facebookButtonLayout.center.x
        fbLoginButton.delegate = self
        fbLoginButton.translatesAutoresizingMaskIntoConstraints = false
        facebookButtonLayout.addSubview(fbLoginButton)
        fbLoginButton.topAnchor.constraint(equalTo: facebookButtonLayout.topAnchor).isActive = true
        fbLoginButton.bottomAnchor
            .constraint(equalTo: facebookButtonLayout.bottomAnchor).isActive = true
        fbLoginButton.leadingAnchor
            .constraint(equalTo: facebookButtonLayout.leadingAnchor).isActive = true
        fbLoginButton.trailingAnchor
            .constraint(equalTo: facebookButtonLayout.trailingAnchor).isActive = true
        
        if(instituteSettings.facebookLoginEnabled) {
            socialLoginLayout.isHidden = false
        }

        // Set firstTextField in super class to hide keyboard on outer side click
        firstTextField = usernameField
        showKeyboardOnStart = false
    }
    
    @IBAction func moveToPasswordField(_ sender: UITextField) {
        // Move focus(cursor) to password field on click next in keyboard from username field
        passwordField.becomeFirstResponder()
    }
    
    @IBAction func onLoginButtonClick(_ sender: UIView) {
        guard let username = usernameField.text, !username.isEmpty else {
            usernameField.becomeFirstResponder()
            return
        }
        guard let password = passwordField.text, !password.isEmpty else {
            passwordField.becomeFirstResponder()
            return
        }
        
        hideKeyboard()
        authenticate(username: username, password: password, provider: .TESTPRESS)
    }
    
    func authenticate(username: String, password: String, provider: AuthProvider) {
        present(alertController, animated: false, completion: nil)
        TPApiClient.authenticate(
            username: username,
            password: password,
            provider: provider,
            completion: {
                testpressAuthToken, error in
                if let error = error {
                    debugPrint(error.message ?? "No error message found")
                    debugPrint(error.kind)
                    var title, description: String
                    if error.isClientError() {
                        title = Strings.WRONG_CREDENTIALS
                        description = Strings.USERNAME_PASSWORD_NOT_MATCHED
                    } else {
                        (_, title, description) = error.getDisplayInfo()
                    }
                    self.alertController.dismiss(animated: true, completion: nil)
                    UIUtils.showSimpleAlert(
                        title: title,
                        message: description,
                        viewController: self,
                        cancelable: true,
                        cancelHandler: #selector(self.closeAlert(gesture:))
                    )
                    return
                }

                let token: String = testpressAuthToken!.token!
                do {
                    // Create a new keychain item
                    let passwordItem = KeychainTokenItem(service: Constants.KEYCHAIN_SERVICE_NAME,
                                                         account: username)
                    
                    // Save the password for the new item
                    try passwordItem.savePassword(token)
                } catch {
                    fatalError("Error updating keychain - \(error)")
                }

                let tabViewController = self.storyboard!.instantiateViewController(
                    withIdentifier: Constants.TAB_VIEW_CONTROLLER)
                
                self.alertController.dismiss(animated: true, completion: nil)
                self.present(tabViewController, animated: true, completion: nil)
            }
        )
    }
    
    @IBAction func showSignUpView() {
        let tabViewController = self.storyboard?.instantiateViewController(withIdentifier:
            Constants.SIGNUP_VIEW_CONTROLLER) as! SignUpViewController
        
        present(tabViewController, animated: true, completion: nil)
    }
    
    @IBAction func showResetPasswordView() {
        let tabViewController = self.storyboard?.instantiateViewController(withIdentifier:
            Constants.RESET_PASSWORD_VIEW_CONTROLLER) as! ResetPasswordViewController
        
        present(tabViewController, animated: true, completion: nil)
    }
    
    @objc func closeAlert(gesture: UITapGestureRecognizer) {
        dismiss(animated: true)
    }

}

extension LoginViewController: LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if (error != nil) {
            print(error)
            return
        }
        
        let token = result?.token
        authenticate(username: (token?.userID)!, password: (token?.tokenString)!, provider: .FACEBOOK)
    }
    
}

