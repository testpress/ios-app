//
//  SignUpViewController.swift
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

class SignUpViewController: BaseTextFieldViewController, UIPickerViewDataSource, UIPickerViewDelegate {


    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var pleaseFillLabel: UILabel!
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var countryCodeField: UITextField!
    @IBOutlet weak var phoneStackView: UIStackView!
    
    let alertController = UIUtils.initProgressDialog(message: Strings.PLEASE_WAIT + "\n\n")
    var instituteSettings: InstituteSettings!
    let countryList = UIUtils.getCountryList()
    var countryCodes: [String]?
    var countryCode: String = "IN"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIUtils.setButtonDropShadow(signUpButton)
        
        // Set firstTextField in super class to set the cursor initialy in the username field
        firstTextField = usernameField
        phoneStackView.isHidden = true
        phoneNumberField.isHidden = true
        instituteSettings = DBManager<InstituteSettings>().getResultsFromDB()[0]
        if (instituteSettings.verificationMethod == "M") {
            phoneNumberField.isHidden = false
            phoneStackView.isHidden = false
        }
        
        countryCodeField.isHidden = false
        countryCodeField.tintColor = UIColor.clear
        if(!instituteSettings.twilioEnabled){
            countryCodeField.isHidden = true
        }
        let pickerView = UIPickerView()
        pickerView.delegate = self
        countryCodeField.inputView = pickerView
        countryCodes = Array(countryList.keys).sorted()
        countryCodeField.text = "91"
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Sets the number of rows in the picker view
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countryCodes!.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countryList[countryCodes![row]]![0]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        countryCode = countryCodes![row]
        countryCodeField.text = countryList[countryCodes![row]]![1]
    }
    
    
    @IBAction func moveToPasswordField(_ sender: UITextField) {
        passwordField.becomeFirstResponder()
    }
    
    @IBAction func moveToEmailField(_ sender: UITextField) {
        // Move focus(cursor) to email field on click next in keyboard from username field
        emailField.becomeFirstResponder()
    }
    
    @IBAction func moveToNextField(_ sender: UITextField) {
        if (phoneNumberField.isHidden) {
            passwordField.becomeFirstResponder()
        } else {
            phoneNumberField.becomeFirstResponder()
        }
    }
    
    @IBAction func moveToConfirmPasswordField(_ sender: UITextField) {
        confirmPasswordField.becomeFirstResponder()
    }
    
    
    @IBAction func onSignUpButtonClick(_ sender: UIView) {
        if validate() {
            hideKeyboard()
            present(alertController, animated: false, completion: nil)
            TPApiClient.registerNewUser(
                username: usernameField.text!,
                email: emailField.text!,
                password: passwordField.text!,
                phone: phoneNumberField.text!,
                country_code: countryCode,
                completion: { response, error in
                    if let error = error {
                        debugPrint(error.message ?? "No error message found")
                        debugPrint(error.kind)
                        self.alertController.dismiss(animated: true, completion: nil)
                        if error.isClientError() {
                            let registrationError = error.getErrorBodyAs(type: RegistrationError.self)
                            if !(registrationError?.username.isEmpty)! {
                                self.setFieldError(textField: self.usernameField,
                                                   errorMessage: (registrationError?.username[0])!)
                            }
                            if !(registrationError?.email.isEmpty)! {
                                self.setFieldError(textField: self.emailField,
                                                   errorMessage: (registrationError?.email[0])!)
                            }
                            if !(registrationError?.password.isEmpty)! {
                                self.confirmPasswordField.text = ""
                                self.setFieldError(textField: self.passwordField,
                                                   errorMessage: (registrationError?.password[0])!)
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
                    if (self.instituteSettings.verificationMethod == "M") {
                        let viewController = self.storyboard?.instantiateViewController(withIdentifier:
                            Constants.VERIFY_PHONE_VIEW_CONTROLLER) as! VerifyPhoneViewController
                        viewController.initVerify(username:self.usernameField.text!, password:self.passwordField.text!)
                        self.alertController.dismiss(animated: true, completion: nil)
                        self.present(viewController, animated: true, completion: nil)

                    } else {
                        let viewController = self.storyboard?.instantiateViewController(withIdentifier:
                            Constants.SUCCESS_VIEW_CONTROLLER) as! SuccessViewController
                        
                        viewController.initSuccessViewController(
                            successDescription: Strings.ACTIVATION_MAIL_SENT,
                            actionButtonText: Strings.LOGIN,
                            backButtonClickHandler: {
                                self.presentingViewController?.dismiss(animated: true)
                        }
                        )
                        self.alertController.dismiss(animated: true, completion: nil)
                        self.present(viewController, animated: true)
                    }
                }
            )
        }
    }
    
    @IBAction func onTextChangeListener() {
        let allDetailsProvided: Bool
        if (phoneNumberField.isHidden) {
            allDetailsProvided = usernameField.hasText && emailField.hasText &&
            passwordField.hasText && confirmPasswordField.hasText
        } else {
            allDetailsProvided = usernameField.hasText && emailField.hasText &&
                passwordField.hasText && confirmPasswordField.hasText && phoneNumberField.hasText
        }
        
        signUpButton.isEnabled = allDetailsProvided
        pleaseFillLabel.isHidden = allDetailsProvided
    }
    
    func validate() -> Bool {
        let usernameRegEx = "[a-z0-9]*"
        let usernameTest = NSPredicate(format:"SELF MATCHES %@", usernameRegEx)
        if !usernameTest.evaluate(with: usernameField.text) {
            setFieldError(textField: usernameField, errorMessage: Strings.ENTER_VALID_USERNAME)
            return false
        }
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        if !emailTest.evaluate(with: emailField.text) {
            setFieldError(textField: emailField, errorMessage: Strings.ENTER_VALID_EMAIL)
            return false
        }
        let passwordText = passwordField.text
        if passwordText == nil || passwordText!.count < 6 {
            confirmPasswordField.text = ""
            setFieldError(textField: passwordField,
                          errorMessage: Strings.PASSWORD_MUST_HAVE_SIX_CHARACTERS)
            return false
        }
        if passwordField.text != confirmPasswordField.text {
            confirmPasswordField.text = ""
            setFieldError(textField: passwordField, errorMessage: Strings.PASSWORD_NOT_MATCH)
            return false
        }
        if (!phoneNumberField.isHidden) {
            let phoneNumberRegEx = "[0-9]{10}"
            let phoneNumberTest = NSPredicate(format:"SELF MATCHES %@", phoneNumberRegEx)
            if !phoneNumberTest.evaluate(with: phoneNumberField.text) {
                setFieldError(textField: phoneNumberField, errorMessage: Strings.ENTER_VALID_PHONE_NUMBER)
                return false
            }
        } else {
            phoneNumberField.text = ""
        }
        return true
    }
    
    func setFieldError(textField: UITextField, errorMessage: String) {
        textField.text = ""
        textField.attributedPlaceholder = NSAttributedString(string: errorMessage,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
        
        textField.becomeFirstResponder()
    }
    
    @objc func closeAlert(gesture: UITapGestureRecognizer) {
        dismiss(animated: true)
    }
    
    @IBAction func back() {
        dismiss(animated: true, completion: nil)
    }

}
