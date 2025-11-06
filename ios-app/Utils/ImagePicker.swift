//
//  ImagePicker.swift
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
// Reference
// https://gist.github.com/DejanEnspyra/869e767a1f5e440894a58e0f5c004398
// https://medium.com/@abhimuralidharan/accessing-photos-in-ios-swift-3-43da29ca4ccb
//

import TOCropViewController
import TTGSnackbar
import UIKit
import CourseKit

public protocol ImagePickerDelegate {
    func imagePicker(_ picker: ImagePicker, didFinishPickingImage imageData: Data,
                     imagePath: String)
}

public class ImagePicker: NSObject {
    
    private var viewController: UIViewController!
    
    public var delegate: ImagePickerDelegate?
    
    public func pickImage(sourceType: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType){
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = sourceType
            viewController.present(pickerController, animated: true, completion: nil)
        } else {
            TTGSnackbar(message: Strings.YOUR_DEVAICE_NOT_SUPPORTED, duration: .middle).show()
        }
    }
    
    public func showImagePicker(viewController: UIViewController) {
        self.viewController = viewController
        let actionSheet = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: UIUtils.getActionSheetStyle()
        )
        actionSheet.addAction(UIAlertAction(
            title: Strings.CAMERA,
            style: .default,
            handler: { (alert:UIAlertAction!) -> Void in
                checkCameraAuthorizationStatus(viewController: viewController, completion: { authorized in
                    DispatchQueue.main.async {
                        if authorized {
                            self.pickImage(sourceType: .camera)
                        }
                    }
                })
                
        }))
        actionSheet.addAction(UIAlertAction(
            title: Strings.PHOTO_LIBRARY,
            style: .default,
            handler: { (alert:UIAlertAction!) -> Void in
                checkPhotoLibraryAuthorizationStatus(viewController: viewController, completion: { authorized in
                    DispatchQueue.main.async {
                        if authorized {
                            self.pickImage(sourceType: .photoLibrary)
                        }
                    }
                })
        }))
        actionSheet.addAction(UIAlertAction(title: Strings.CANCEL, style: .default, handler: nil))
        viewController.present(actionSheet, animated: true, completion: nil)
    }
    
}

extension ImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc public func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        picker.dismiss(animated: true, completion: nil)
        if let originalImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            let controller = TOCropViewController(image: originalImage)
            controller.delegate = self
            let navController = UINavigationController(rootViewController: controller)
            viewController.present(navController, animated: true, completion: nil)
        } else {
            TTGSnackbar(message: Strings.INVALID_IMAGE, duration: .middle).show()
        }
    }
}

extension ImagePicker: TOCropViewControllerDelegate {
    public func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int)
    {
        cropViewController.dismiss(animated: true)
        
        let documentDirectory: NSString = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true).first! as NSString
        
        // https://medium.com/@adinugroho/upload-image-from-ios-app-using-alamofire-ecc6ad7fccc
        // Set static name, so everytime image is cloned, it will be named "temp",
        // thus rewrite the last "temp" image. Don't worry it won't be shown in Photos app.
        let imageName = "temp"
        let imageURL = URL(string: documentDirectory.appendingPathComponent(imageName))!
        let data = image.jpegData(compressionQuality: 0)!
        do {
            try data.write(to: imageURL)
        } catch {
            debugPrint("NSSearchPathForDirectoriesInDomains wrong path")
        }
        delegate?.imagePicker(self, didFinishPickingImage: data, imagePath: imageURL.absoluteString)
    }
    
    
    public func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool)
    {
        cropViewController.dismiss(animated: true) { () -> Void in  }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
