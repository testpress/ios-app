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

class FileUploadHelper: NSObject {
    private var filePickerController: UIDocumentPickerViewController?
    private var uploadCompletionCallback: ((String?, Error?) -> Void)?
    private var presentingViewController: UIViewController
    private var fileUploadPath: String
    
    init(presentingViewController: UIViewController, fileUploadPath: String){
        self.presentingViewController = presentingViewController
        self.fileUploadPath = fileUploadPath
        super.init()
    }

    func showFileSelectorAndUpload(callback: @escaping (String?, Error?) -> Void) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.data"], in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        
        filePickerController = documentPicker
        uploadCompletionCallback = callback
        
        presentingViewController.present(documentPicker, animated: true, completion: nil)
    }
}

extension FileUploadHelper: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let fileURL = urls.first else {
            return
        }

        uploadFileWithPreSignedURL(from: fileURL) { uploadedPath, error in
            self.uploadCompletionCallback?(uploadedPath, error)
            self.filePickerController = nil
            self.uploadCompletionCallback = nil
        }
    }
    
    private func uploadFileWithPreSignedURL(from fileURL: URL, completion: @escaping (String?, Error?) -> Void) {
        getPresignedURL(fileName: fileURL.lastPathComponent) { presignedURL, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let presignedURL = presignedURL else {
                completion(nil, NSError(domain: "FileUploadHelper", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get presigned URL"]))
                return
            }
            
            self.uploadFile(from: fileURL, to: presignedURL) { uploadError in
                if let uploadError = uploadError {
                    completion(nil, uploadError)
                } else {
                    let uploadedPath = self.extractUploadedPath(from: presignedURL.path)
                    completion(uploadedPath, nil)
                }
            }
        }
    }

    private func getPresignedURL(fileName: String, completion: @escaping (URL?, Error?) -> Void) {
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

    private func uploadFile(from fileURL: URL, to presignedURL: URL, completion: @escaping (Error?) -> Void) {
        let headers: HTTPHeaders = ["Content-Type": "multipart/form-data", "x-amz-acl": "public-read"]
        let formData = MultipartFormData()

        do {
            let fileData = try Data(contentsOf: fileURL)
            formData.append(fileData, withName: "file", fileName: fileURL.lastPathComponent, mimeType: "application/octet-stream")
        } catch {
            completion(error)
            return
        }

        AF.upload(
            multipartFormData: formData,
            to: presignedURL,
            usingThreshold: .max,
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
        
        let substring = String(path[startIndex...])
        return substring
    }
}

