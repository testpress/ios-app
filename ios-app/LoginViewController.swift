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

class LoginViewController: UIViewController, UITextFieldDelegate {

    // MARK: Properties
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        print("textFieldShouldReturn")
        textField.resignFirstResponder()
        if (textField == usernameTextField) {
            passwordTextField.becomeFirstResponder()
        } else if (textField == passwordTextField) {
            onLoginButtonClick(loginButton)
        }
        return true
    }
    
    @IBAction func onLoginButtonClick(_ sender: UIButton) {
        print("onLoginButtonClick")
        let username = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        if (!username.isEmpty && !password.isEmpty) {
            TPApiClient.authenticate(username: username, password: password, completion: {
                testpressAuthToken, error in
                if let error = error {
                    print(error.message ?? "No error")
                    print(error.kind)
                    switch (error.kind) {
                    case .network:
                        print("Internet Unavailable")
                    case .unauthenticated:
                        print("Authorization Required")
                    case .http:
                        print("HTTP error occured")
                    default:
                        print("Unexpected")
                    }
                    return
                }
                
                let token: String = testpressAuthToken!.token!
                
                do {
                    // create a new keychain item with the account name.
                    let passwordItem = KeychainTokenItem(service: Constants.KEYCHAIN_SERVICE_NAME_TOKEN,
                                                         account: username)
                    
                    // Save the password for the new item.
                    try passwordItem.savePassword(token)
                } catch {
                    fatalError("Error updating keychain - \(error)")
                }
                
                let tabViewController = self.storyboard?.instantiateViewController(withIdentifier:
                    Constants.TAB_VIEW_CONTROLLER) as! TabViewController
                let navigationController = UINavigationController(rootViewController: tabViewController)
                self.present(navigationController, animated: true, completion: nil)
            })
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }

}

