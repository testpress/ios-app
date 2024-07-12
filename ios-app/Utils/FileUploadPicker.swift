//
//  FileUploadHelper.swift
//  ios-app
//
//  Created by Hari on 11/07/24.
//  Copyright © 2024 Testpress. All rights reserved.
//

import Foundation
import Alamofire
import UIKit

class FileUploadPicker: NSObject {
    private var filePickerController: UIDocumentPickerViewController?
    private var uploadCompletionCallback: ((String?, Error?) -> Void)?
    private var presentingViewController: UIViewController
    private var fileUploadPath: String
    private var maxFileInMb: Double
    
    init(presentingViewController: UIViewController, fileUploadPath: String, maxFileInMb: Double) {
        self.presentingViewController = presentingViewController
        self.fileUploadPath = fileUploadPath
        self.maxFileInMb = maxFileInMb
        super.init()
    }

    func presentFileSelector(callback: @escaping (String?, Error?) -> Void) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [
            "com.microsoft.word.doc",
            "com.microsoft.excel.xls",
            "com.microsoft.powerpoint.​ppt",
            "public.text",
            "public.plain-text",
            "public.image",
            "com.adobe.pdf",
            
        ], in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        
        filePickerController = documentPicker
        uploadCompletionCallback = callback
        
        presentingViewController.present(documentPicker, animated: true, completion: nil)
    }
}

extension FileUploadPicker: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let fileURL = urls.first else {
            return
        }
        
         if isFileSizeExceedsLimit(fileURL: fileURL) {
             let error = NSError(domain: "FileUploadHelper", code: -1, userInfo: [NSLocalizedDescriptionKey: "File is too large. Maximum allowed size is \(maxFileInMb) MB."])
             self.uploadCompletionCallback?(nil, error)
             return
         }
        
        
        let progressDialog = UIUtils.initProgressDialog(message: "Uploading...\n\n")
        presentingViewController.present(progressDialog, animated: true, completion: nil)

        uploadFile(fileURL) { uploadedPath, error in
            self.uploadCompletionCallback?(uploadedPath, error)
            self.filePickerController = nil
            self.uploadCompletionCallback = nil
            
            self.presentingViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    private func isFileSizeExceedsLimit(fileURL: URL) -> Bool {
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            if let fileSize = fileAttributes[.size] as? NSNumber {
                let fileSizeInMB = fileSize.doubleValue / (1024.0 * 1024.0)
                return fileSizeInMB > maxFileInMb
            }
        } catch {
            print("Error getting file size: \(error.localizedDescription)")
        }
        return false
    }

    
    private func uploadFile(_ fileURL: URL, completion: @escaping (String?, Error?) -> Void) {
        requestPresignedURL(for: fileURL.lastPathComponent) { presignedURL, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let presignedURL = presignedURL else {
                completion(nil, NSError(domain: "FileUploadHelper", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get presigned URL"]))
                return
            }
            
            self.uploadToPresignedURL(fileURL, presignedURL: presignedURL) { uploadError in
                if let uploadError = uploadError {
                    completion(nil, uploadError)
                } else {
                    let uploadedPath = self.extractUploadedPath(from: presignedURL.path)
                    completion(uploadedPath, nil)
                }
            }
        }
    }

    private func requestPresignedURL(for fileName: String, completion: @escaping (URL?, Error?) -> Void) {
        var parameters: [String: Any] = ["filename": fileName]
        parameters["folder"] = self.fileUploadPath

        TPApiClient.apiCall(endpointProvider: TPEndpointProvider(.getS3PreSignedUrl), parameters: parameters) { response, error in
            if let error = error {
                completion(nil, error)
            } else if let unwrappedUrlString = response?.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\"", with: ""),
                      let presignedURL = URL(string: unwrappedUrlString) {
                completion(presignedURL, nil)
            } else {
                completion(nil, NSError(domain: "FileUploadHelper", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid presigned URL format"]))
            }
        }
    }

    private func uploadToPresignedURL(_ fileURL: URL, presignedURL: URL, completion: @escaping (Error?) -> Void) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/octet-stream",
            "x-amz-acl": "public-read"
        ]
        
        AF.upload(
            fileURL,
            to: presignedURL,
            method: .put,
            headers: headers,
            interceptor: nil,
            fileManager: .default
        )
        .uploadProgress { progress in
            print("Upload Progress: \(progress.fractionCompleted)")
        }
        .validate()
        .response { response in
            if let error = response.error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    private func extractUploadedPath(from path: String) -> String? {
        guard let startIndex = path.range(of: "/institute/")?.lowerBound else {
            return nil
        }
        
        return String(path[startIndex...])
    }
}
