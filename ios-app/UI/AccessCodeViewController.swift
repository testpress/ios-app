//
//  AccessCodeViewController.swift
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

import TTGSnackbar
import UIKit

class AccessCodeViewController: BaseTextFieldViewController {
    
    @IBOutlet weak var accessCode: UITextField!
    
    let alertController = UIUtils.initProgressDialog(message: "Please wait\n\n")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIUtils.setButtonDropShadow(accessCode)
        firstTextField = accessCode
        showKeyboardOnStart = false
        accessCode.defaultTextAttributes
            .updateValue(10.0, forKey: NSAttributedStringKey.kern.rawValue)
    }
    
    @IBAction func getExams() {
        if accessCode.text != nil && !accessCode.text!.isEmpty {
            accessCode.resignFirstResponder()
            present(alertController, animated: false, completion: nil)
            let url = Constants.BASE_URL + TPEndpoint.getAccessCodeExams.urlPath + accessCode.text!
                + TPEndpoint.examsPath.urlPath
            
            TPApiClient.getListItems(
                endpointProvider: TPEndpointProvider(.getAccessCodeExams, url: url),
                completion: {
                    response, error in
                    if let error = error {
                        debugPrint(error.message ?? "No error")
                        debugPrint(error.kind)
                        self.alertController.dismiss(animated: false, completion: nil)
                        var (_, _, description) = error.getDisplayInfo()
                        if error.isClientError() {
                            description = Strings.INVALID_ACCESS_CODE
                        }
                        TTGSnackbar(message: description, duration: .middle).show()
                        return
                    }
                    
                    self.alertController.dismiss(animated: false, completion: nil)
                    self.showExamsList(exams: response!.results)
                },
                type: Exam.self
            )
        }
    }
    
    func showExamsList(exams: [Exam]) {
        let storyboard = UIStoryboard(name: Constants.TEST_ENGINE, bundle: nil)
        let navigationController = storyboard.instantiateViewController(withIdentifier:
            Constants.ACCESS_CODE_EXAMS_NAVIGATION_CONTROLLER) as! UINavigationController
        
        let viewController = navigationController.viewControllers.first
            as! AccessCodeExamsViewController
        
        viewController.accessCode = accessCode.text!
        present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func showProfileDetails(_ sender: UIBarButtonItem) {
        UIUtils.showProfileDetails(self)
    }
    
}
