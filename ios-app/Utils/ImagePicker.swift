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

import PhotoCropEditor
import TTGSnackbar
import UIKit

protocol ImagePickerDelegate {
    func imagePicker(_ picker: ImagePicker, didFinishPickingImage imageData: Data,
                     imagePath: String)
}

class ImagePicker: NSObject {
    
    private var viewController: UIViewController!
    
    var delegate: ImagePickerDelegate?
    
    func pickImage(sourceType: UIImagePickerControllerSourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType){
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = sourceType
            viewController.present(pickerController, animated: true, completion: nil)
        }
    }
    
    func showActionSheet(viewController: UIViewController) {
        self.viewController = viewController
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(
            title: Strings.CAMERA,
            style: .default,
            handler: { (alert:UIAlertAction!) -> Void in
                checkCameraAuthorizationStatus(viewController: viewController, completion: {
                    authorized in
                    if authorized {
                        self.pickImage(sourceType: .camera)
                    }
                })
                
        }))
        actionSheet.addAction(UIAlertAction(
            title: Strings.PHOTO_LIBRARY,
            style: .default,
            handler: { (alert:UIAlertAction!) -> Void in
                checkPhotoLibraryAuthorizationStatus(viewController: viewController, completion: {
                    authorized in
                    if authorized {
                        self.pickImage(sourceType: .photoLibrary)
                    }
                })
        }))
        actionSheet.addAction(UIAlertAction(title: Strings.CANCEL, style: .default, handler: nil))
        viewController.present(actionSheet, animated: true, completion: nil)
    }
    
}

extension ImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let controller = CropViewController()
            controller.delegate = self
            controller.image = originalImage
            controller.toolbarHidden = true
            let navController = UINavigationController(rootViewController: controller)
            viewController.present(navController, animated: true, completion: nil)
        } else {
            TTGSnackbar(message: Strings.INVALID_IMAGE, duration: .middle).show()
        }
    }
}

extension ImagePicker: CropViewControllerDelegate {
    
    func cropViewController(_ controller: CropViewController,
                            didFinishCroppingImage image: UIImage) {
        
        controller.dismiss(animated: true, completion: nil)
        let documentDirectory: NSString = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true).first! as NSString
        
        // https://medium.com/@adinugroho/upload-image-from-ios-app-using-alamofire-ecc6ad7fccc
        // Set static name, so everytime image is cloned, it will be named "temp",
        // thus rewrite the last "temp" image. Don't worry it won't be shown in Photos app.
        let imageName = "temp"
        let imageURL = URL(string: documentDirectory.appendingPathComponent(imageName))!
        let data = UIImageJPEGRepresentation(image, 1)!
        do {
            try data.write(to: imageURL)
        } catch {
            debugPrint("NSSearchPathForDirectoriesInDomains wrong path")
        }
        delegate?.imagePicker(self, didFinishPickingImage: data, imagePath: imageURL.absoluteString)
    }
    
    func cropViewController(_ controller: CropViewController, didFinishCroppingImage image: UIImage,
                            transform: CGAffineTransform, cropRect: CGRect) {
    }
    
    func cropViewControllerDidCancel(_ controller: CropViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
