//
//  OTPLoginViewController.swift
//  ios-app
//
//  Created by Balamurugan on 02/12/25.
//  Copyright © 2025 Testpress. All rights reserved.
//

import CourseKit
import UIKit
import RealmSwift

final class OTPLoginViewController: BaseTextFieldViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet private var phoneField: UITextField!
    @IBOutlet private var otpField: UITextField!
    @IBOutlet private var sendOtpButton: UIButton!
    @IBOutlet private var verifyOtpButton: UIButton!
    @IBOutlet private var resendOtpButton: UIButton!
    @IBOutlet weak var usernamePasswordNavigateButton: UIButton!
    @IBOutlet weak var countryCodeField: UITextField!
    @IBOutlet weak var navigationbarItem: UINavigationItem!
    @IBOutlet private var phonestack: UIStackView!
    @IBOutlet private var otpstack: UIStackView!
    
    private var phoneNumber = ""
    private let loadingDialog = UIUtils.initProgressDialog(message: Strings.PLEASE_WAIT + "\n\n")
    private var countdownTimer: Timer?
    private let cooldownSeconds = 30
    private var remainingSeconds = 0
    
    private let countryList = UIUtils.getCountryList()
    private var countryCodes: [String]?
    private var countryCode = "IN"
    
    var instituteSettings: InstituteSettings!
    var instituteSettingsToken: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStatusBarColor()
        observeInstituteSettings()
        configureUI()
        firstTextField = phoneField
        showKeyboardOnStart = true
    }
    
    deinit {
        countdownTimer?.invalidate()
        instituteSettingsToken?.invalidate()
    }
    
    private func configureUI() {
        navigationItem.title = "Login"
        navigationbarItem.title = Constants.getAppName()
        otpstack.isHidden = true
        usernamePasswordNavigateButton.isHidden = true
        
        configureCountryCodePicker()
        configureTextFields()
    }
    
    private func configureCountryCodePicker() {
        countryCodeField.tintColor = .clear
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        countryCodeField.inputView = pickerView
        countryCodes = Array(countryList.keys).sorted()
        countryCodeField.text = "91"
    }
    
    private func configureTextFields() {
        phoneField.keyboardType = .phonePad
        otpField.keyboardType = .numberPad
    }
    
    private func observeInstituteSettings() {
        instituteSettingsToken = InstituteRepository.shared.observeSettingsChanges { [weak self] settings in
            guard let self = self, let settings = settings else { return }
            self.instituteSettings = settings
            self.usernamePasswordNavigateButton.isHidden = !settings.isUsernameLoginMethodAllowed()
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        countryCodes?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let codes = countryCodes else { return nil }
        return countryList[codes[row]]?[0]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let codes = countryCodes else { return }
        countryCode = codes[row]
        countryCodeField.text = countryList[codes[row]]?[1]
    }
    
    @IBAction private func onSendOtp(_: Any) {
        guard let phone = phoneField.text, !phone.isEmpty else {
            phoneField.becomeFirstResponder()
            return
        }
        
        guard validatePhoneNumber(phone) else {
            setFieldError(textField: phoneField, errorMessage: Strings.ENTER_VALID_PHONE_NUMBER)
            return
        }
        
        phoneNumber = phone
        hideKeyboard()
        present(loadingDialog, animated: false)
        sendOtp()
    }
    
    @IBAction private func onVerifyOtp(_: Any) {
        guard let otp = otpField.text, !otp.isEmpty else {
            otpField.becomeFirstResponder()
            return
        }
        
        guard validateOTP(otp) else {
            setFieldError(textField: otpField, errorMessage: "Please enter a valid 4-digit OTP")
            return
        }
        
        hideKeyboard()
        present(loadingDialog, animated: false)
        verifyOtp(code: otp)
    }
    
    @IBAction private func onResendOtp(_: Any) {
        guard remainingSeconds == 0 else {
            showAlert(message: "Please wait \(remainingSeconds)s before requesting a new OTP.")
            return
        }
        
        hideKeyboard()
        present(loadingDialog, animated: false)
        sendOtp()
    }
    
    @IBAction private func useUsernameLogin(_: Any) {
        let loginVC = storyboard?.instantiateViewController(
            withIdentifier: Constants.LOGIN_VIEW_CONTROLLER
        ) as! LoginViewController
        present(loginVC, animated: true)
    }
    
    private func sendOtp() {
        TPApiClient.generateOtp(
            phoneNumber: phoneNumber,
            countryCode: countryList[countryCode]?[1] ?? "91"
        ) { [weak self] error in
            guard let self = self else { return }
            self.loadingDialog.dismiss(animated: true)
            
            if let error = error {
                self.showAlert(message: self.parseErrorMessage(from: error))
            } else {
                self.showOtpEntryUI()
                self.startResendCooldown()
            }
        }
    }
    
    private func verifyOtp(code: String) {
        TPApiClient.otpLogin(
            otp: code,
            phoneNumber: phoneNumber
        ) { [weak self] authToken, error in
            guard let self = self else { return }
            self.loadingDialog.dismiss(animated: true)
            
            if let error = error {
                self.showAlert(message: self.parseErrorMessage(from: error))
                return
            }
            
            guard let token = authToken, let tokenString = token.token else {
                self.showAlert(message: "Invalid response from server. Please try again.")
                return
            }
            
            self.handleSuccessfulLogin(token: tokenString)
        }
    }
    
    private func handleSuccessfulLogin(token: String) {
        do {
            let passwordItem = KeychainTokenItem(
                service: Constants.KEYCHAIN_SERVICE_NAME,
                account: phoneNumber
            )
            try passwordItem.savePassword(token)
            
            TestpressCourse.shared.initialize(
                withToken: token,
                subdomain: AppConstants.SUBDOMAIN,
                primaryColor: AppConstants.PRIMARY_COLOR
            )
            
            navigateToHome()
        } catch {
            showAlert(message: "Failed to save authentication. Please try again.")
        }
    }
    
    private func showOtpEntryUI() {
        otpstack.isHidden = false
        phonestack.isHidden = true
        otpField.becomeFirstResponder()
    }
    
    private func startResendCooldown() {
        resendOtpButton.isEnabled = false
        remainingSeconds = cooldownSeconds
        resendOtpButton.alpha = 0.8
        updateResendButtonTitle()
        
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.remainingSeconds -= 1
            
            if self.remainingSeconds > 0 {
                self.updateResendButtonTitle()
            } else {
                timer.invalidate()
                self.resendOtpButton.isEnabled = true
                self.resendOtpButton.alpha = 1.0
                self.resendOtpButton.setTitle("Resend OTP", for: .normal)
            }
        }
    }
    
    private func updateResendButtonTitle() {
        resendOtpButton.setTitle("Resend OTP (\(remainingSeconds)s)", for: .disabled)
    }
    
    // MARK: - Validation
    private func validatePhoneNumber(_ phoneNumber: String) -> Bool {
        let regex = "[0-9]{10}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: phoneNumber)
    }
    
    private func validateOTP(_ otp: String) -> Bool {
        let regex = "[0-9]{4}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: otp)
    }
    
    private func setFieldError(textField: UITextField, errorMessage: String) {
        textField.text = ""
        textField.attributedPlaceholder = NSAttributedString(
            string: errorMessage,
            attributes: [.foregroundColor: UIColor.red]
        )
        textField.becomeFirstResponder()
    }
    
    private func parseErrorMessage(from error: TPError) -> String {
        guard let message = error.message,
              let data = message.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data),
              let json = jsonObject as? [String: Any] else {
            return error.message ?? "An error occurred. Please try again."
        }
        
        if let nonFieldErrors = json["non_field_errors"] as? [String], let first = nonFieldErrors.first {
            return first
        }
        
        for (key, value) in json {
            if let errors = value as? [String], let first = errors.first {
                return "\(key): \(first)"
            }
        }
        
        return error.message ?? "An error occurred. Please try again."
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func navigateToHome() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let window = appDelegate.window else { return }
        
        let vc = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: Constants.TAB_VIEW_CONTROLLER)
        window.rootViewController = vc
    }
}
