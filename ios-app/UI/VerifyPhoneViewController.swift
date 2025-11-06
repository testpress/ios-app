//
//  VerifyPhoneViewController.swift
//  ios-app
//
//  Created by Karthik on 27/12/18.
//  Copyright © 2018 Testpress. All rights reserved.
//

import UIKit
import CourseKit

class VerifyPhoneViewController: UIViewController {
    
    
    @IBOutlet weak var verifyCodeButton: UIButton!
    @IBOutlet weak var otpField: UITextField!
    let alertController = UIUtils.initProgressDialog(message: Strings.PLEASE_WAIT + "\n\n")
    var username: String?
    var password: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIUtils.setButtonDropShadow(verifyCodeButton)
    }
    
    func initVerify(username:String, password:String) {
        self.username = username
        self.password = password
    }
    
    
    @IBAction func verifyCode(_ sender: Any) {
        if validate() {
            self.present(alertController, animated: false, completion: nil)
            TPApiClient.verifyPhoneNumber(
                username: username!,
                code: otpField.text!,
                completion: { error in
                    if let error = error {
                        debugPrint(error.message ?? "No error message found")
                        debugPrint(error.kind)
                        self.alertController.dismiss(animated: true, completion: nil)
                        if error.isClientError() {
                            let registrationError = error.getErrorBodyAs(type: RegistrationError.self)
                            if !(registrationError?.non_field_errors.isEmpty)! {
                                self.setFieldError(textField: self.otpField,
                                                   errorMessage: (registrationError?.non_field_errors[0])!)
                            }
                        }
                        return
                    }
                    self.authenticate(username: self.username!, password: self.password!, provider: .TESTPRESS)
            }
            )
        }
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func validate() -> Bool {
        let otpRegEx = "[0-9]*"
        let otpTest = NSPredicate(format:"SELF MATCHES %@", otpRegEx)
        if !otpTest.evaluate(with: otpField.text) {
            setFieldError(textField: otpField, errorMessage: Strings.ENTER_VALID_USERNAME)
            return false
        }
        return true
    }
    
    func setFieldError(textField: UITextField, errorMessage: String) {
        textField.text = ""
        textField.attributedPlaceholder = NSAttributedString(string: errorMessage,
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
        textField.becomeFirstResponder()
    }
    
    func authenticate(username: String, password: String, provider: AuthProvider) {
        TPApiClient.authenticate(
            username: username,
            password: password,
            provider: provider,
            completion: {
                testpressAuthToken, error in
                if let error = error {
                    debugPrint(error.message ?? "No error message found")
                    debugPrint(error.kind)
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier:
                        Constants.LOGIN_VIEW_CONTROLLER) as! LoginViewController
                    
                    self.alertController.dismiss(animated: true, completion: nil)
                    self.present(viewController, animated: true, completion: nil)
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
                let storyboard = UIStoryboard(name: "Main", bundle: nil)

                let tabViewController = storyboard.instantiateViewController(
                    withIdentifier: Constants.TAB_VIEW_CONTROLLER)
                
                self.alertController.dismiss(animated: true, completion: nil)
                self.present(tabViewController, animated: true, completion: nil)
        }
        )
    }
    
    @objc func closeAlert(gesture: UITapGestureRecognizer) {
        dismiss(animated: true)
    }
}
