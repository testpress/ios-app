//
//  MediaPicker.swift
//  ios-app
//
//  Created by Karthik on 12/07/21.
//  Copyright © 2021 Testpress. All rights reserved.
//

import UIKit
import MobileCoreServices

enum MediaType {
    case image
    case media
    case all
}


class MediaPicker: NSObject {
    static let shared: MediaPicker = MediaPicker()
    
    fileprivate var viewController: UIViewController!
    var imagePickerBlock: ((_ image: UIImage) -> Void)?
    var videoPickerBlock: ((_ data: Data?) -> Void)?
    var filePickerBlock: ((_ url: URL) -> Void)?
    
    
    fileprivate func camera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let pickerController = UIImagePickerController()
            //            pickerController.delegate = self
            pickerController.sourceType = .camera
            viewController.present(pickerController, animated: true, completion: nil)
        }
    }
    
    fileprivate func video() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let pickerController = UIImagePickerController()
            //            pickerController.delegate = self
            pickerController.sourceType = .photoLibrary
            pickerController.mediaTypes = [kUTTypeMovie as String, kUTTypeVideo as String]
            viewController.present(pickerController, animated: true, completion: nil)
        }
    }
    
    fileprivate func photoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let pickerController = UIImagePickerController()
            //            pickerController.delegate = self
            pickerController.sourceType = .photoLibrary
            viewController.present(viewController, animated: true, completion: nil)
        }
    }
    
    fileprivate func file() {
        var pickerController = UIDocumentPickerViewController(documentTypes: ["*"], in: .import)
        //        pickerController.delegate = self
        if #available(iOS 11.0, *) {
            pickerController.allowsMultipleSelection = true
        }
        viewController.present(pickerController, animated: true, completion: nil)
    }
    
    func showActions(viewController: UIViewController, type: MediaType) {
        self.viewController = viewController
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: Constants.CAMERA, style: .default, handler: {_ in self.camera()})
        let gallery = UIAlertAction(title: Constants.GALLERY, style: .default, handler: {_ in self.photoLibrary()})
        let video = UIAlertAction(title: Constants.VIDEO, style: .default, handler: {_ in self.video()})
        let file = UIAlertAction(title: Constants.FILE, style: .default, handler: {_ in self.file()})
        let cancel = UIAlertAction(title: Constants.CANCEL, style: .cancel, handler: nil)
        
        actionSheet.addAction(camera)
        actionSheet.addAction(gallery)
        if type == .media {
            actionSheet.addAction(video)
        } else if type == .all {
            actionSheet.addAction(video);
            actionSheet.addAction(file)
        }
        actionSheet.addAction(cancel)
        viewController.present(actionSheet, animated: true, completion: nil)
    }
}


extension  MediaPicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        viewController.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage {
            imagePickerBlock?(image)
        } else {
            print("Image was not picked")
        }
        
        if let videoURL = info[UIImagePickerController.InfoKey.mediaType.rawValue] as? URL {
            let data = try? Data(contentsOf: videoURL)
            videoPickerBlock?(data)
        } else {
            print("Video was not picked")
        }
        
        viewController.dismiss(animated: true, completion: nil)
    }
}


extension MediaPicker: UIDocumentMenuDelegate, UIDocumentPickerDelegate {
    func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        viewController.present(documentPicker, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        filePickerBlock?(url)
    }
    
    func documentMenuWasCancelled(_ documentMenu: UIDocumentMenuViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
}
