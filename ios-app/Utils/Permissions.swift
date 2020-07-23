//
//  Permissions.swift
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

import AVFoundation
import Photos
import TTGSnackbar
import UIKit

func checkCameraAuthorizationStatus(viewController: UIViewController,
                                    completion: @escaping (Bool) -> Void) {
    
    let cameraMediaType = AVMediaType.video
    let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType)
    let message = Strings.NEEDS_PERMISSION_TO_ACCESS + Strings.CAMERA
    switch cameraAuthorizationStatus {
    case .authorized:
        completion(true)
        break
        
    case .restricted:
        TTGSnackbar(message:  message, duration: .middle).show()
        completion(false)
        break
        
    case .notDetermined:
        // Prompting user for the permission to use the camera.
        AVCaptureDevice.requestAccess(for: cameraMediaType) { granted in
            completion(granted)
        }
        
    case .denied:
        showGoToSettingsAlert(title: message, viewController: viewController)
        break
    }
}

func checkPhotoLibraryAuthorizationStatus(viewController: UIViewController,
                                          completion: @escaping (Bool) -> Void) {
    
    let message = Strings.NEEDS_PERMISSION_TO_ACCESS + Strings.PHOTO_LIBRARY
    let status = PHPhotoLibrary.authorizationStatus()
    switch status {
    case .authorized:
        completion(true)
        break
        
    case .restricted:
        TTGSnackbar(message:  message, duration: .middle).show()
        completion(false)
        break
        
    case .notDetermined:
        PHPhotoLibrary.requestAuthorization() { status in
            completion( status == .authorized ? true : false)
        }
    
    case .denied:
        showGoToSettingsAlert(title: message, viewController: viewController)
        break
    }
}

func showGoToSettingsAlert(title: String, viewController: UIViewController) {
    
    let alertController = UIAlertController (title: title, message: Strings.GO_TO_SETTINGS,
                                             preferredStyle: .alert)
    
    let settingsAction =
        UIAlertAction(title: Strings.SETTINGS, style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                } else {
                    UIApplication.shared.openURL(settingsUrl)
                }
            }
    }
    alertController.addAction(settingsAction)
    let cancelAction = UIAlertAction(title: Strings.CANCEL, style: .default, handler: nil)
    alertController.addAction(cancelAction)
    viewController.present(alertController, animated: true, completion: nil)
}
