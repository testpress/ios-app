//
//  ImageUploadHelper.swift
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

public protocol ImageUploadHelperDelegate {
    func imageUploadHelper(_ helper: ImageUploadHelper, didFinishUploadImage imageUrl: String)
}

public class ImageUploadHelper: NSObject {
    
    private var viewController: UIViewController!
    private var loadingDialogController: UIAlertController!
    private let imagePicker = ImagePicker()
    
    public var delegate: ImageUploadHelperDelegate?
    
    public func showImagePicker(viewController: UIViewController,
                         loadingDialogController: UIAlertController) {
        
        self.viewController = viewController
        self.loadingDialogController = loadingDialogController
        imagePicker.delegate = self
        imagePicker.showImagePicker(viewController: viewController)
    }
}

extension ImageUploadHelper: ImagePickerDelegate {
    
    public func imagePicker(_ picker: ImagePicker, didFinishPickingImage imageData: Data,
                     imagePath: String) {
        
        viewController.present(loadingDialogController, animated: false, completion: {
            TPApiClient.uploadImage(imageData: imageData, fileName: imagePath, completion: {
                fileDetails, error in
                
                if let error = error {
                    debugPrint(error.message ?? "No error")
                    debugPrint(error.kind)
                    self.loadingDialogController.dismiss(animated: false)
                    let title = "Something went wrong, Please try again."
                    TTGSnackbar(message: title, duration: .middle).show()
                    return
                }
                
                self.delegate?.imageUploadHelper(self, didFinishUploadImage: fileDetails!.url)
            })
        })
    }
}
