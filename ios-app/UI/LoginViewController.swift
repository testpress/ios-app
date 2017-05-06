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
import UIKit

class LoginViewController: UIViewController {

    // MARK: Properties
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var navigationbarItem: UINavigationItem!
    @IBOutlet weak var loginButton: UIButton!
    
    let alertController = UIUtils.initProgressDialog(message: Strings.PLEASE_WAIT + "\n\n")
    
    override func viewDidLoad() {
        // Set login button shadow
        loginButton.layer.shadowColor = UIColor.lightGray.cgColor
        loginButton.layer.shadowOffset = CGSize(width:0, height: 2)
        loginButton.layer.shadowOpacity = 0.9;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationbarItem.title = Constants.APP_NAME
        
        // Add tap gesture to hide keyboard on outside click
        let tapGesture = UITapGestureRecognizer(target: self, action:
            #selector(hideKeyboard(gesture:)))
        
        view.addGestureRecognizer(tapGesture)
        
        // Display keyboard initialy with cursor on username field
        usernameField.becomeFirstResponder()
    }
    
    @IBAction func moveToPasswordField(_ sender: UITextField) {
        // Move focus(cursor) to password field on click next in keyboard from username field
        passwordField.becomeFirstResponder()
    }
    
    func hideKeyboard(gesture: UITapGestureRecognizer? = nil) {
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
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
        present(alertController, animated: false, completion: nil)
        
        TPApiClient.authenticate(username: username, password: password, completion: {
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
                let passwordItem = KeychainTokenItem(service: Constants.KEYCHAIN_SERVICE_NAME_TOKEN,
                                                     account: username)
                
                // Save the password for the new item
                try passwordItem.savePassword(token)
            } catch {
                fatalError("Error updating keychain - \(error)")
            }
            
            let tabViewController = self.storyboard?.instantiateViewController(withIdentifier:
                Constants.TAB_VIEW_CONTROLLER) as! TabViewController
            
            self.alertController.dismiss(animated: true, completion: nil)
            self.present(tabViewController, animated: true, completion: nil)
            self.dismiss(animated: true)
        })
    }
    
    func closeAlert(gesture: UITapGestureRecognizer) {
        dismiss(animated: true)
    }

}

