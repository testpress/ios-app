//
//  PreviewPDFViewController.swift
//  ios-app
//
//  Created by Pruthivi Raj on 10/06/25.
//  Copyright © 2025 Testpress. All rights reserved.
//

import Foundation
import WebKit
import UIKit

class PreviewPDFViewController: WebViewController, WKScriptMessageHandler, UIDocumentInteractionControllerDelegate {

    private var documentInteractionController: UIDocumentInteractionController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStatusBarColor()
    }

    override func initWebView() {
        let contentController = WKUserContentController()
        contentController.add(self, name: "openPdf")
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        config.preferences.javaScriptEnabled = true
        webView = WKWebView(frame: parentView.bounds, configuration: config)
        webView.customUserAgent = "TestpressiOSApp/WebView"
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "openPdf" {
            if let body = message.body as? [String: Any] {
                guard let pdfUrlString = body["url"] as? String,
                      let authKey = body["key"] as? String,
                      let url = URL(string: pdfUrlString) else {
                    showErrorDialog(message: "Missing URL or Auth Key for PDF.")
                    return
                }
                let pdfName = (body["name"] as? String) ?? "response.pdf"
                handleDownloadFile(url: pdfUrlString, authKey: authKey, fileName: pdfName)
            } else {
                showErrorDialog(message: "Invalid data received from web view.")
            }
        }
    }
    
    
    func handleDownloadFile(url: String, authKey: String, fileName: String) {
        guard let fileUrl = URL(string: url) else {
            print("Invalid URL.")
            return
        }
        
        var request = URLRequest(url: fileUrl)
        request.addValue(authKey, forHTTPHeaderField: "Authorization")

        FileDownloadUtility.shared.downloadFile(viewController: self, from: request, fileName: fileName) { (destinationURL, error) in
            if let destinationURL = destinationURL {
                debugPrint(destinationURL)
            } else if let error = error {
                self.presentErrorDialog(error: error)
            }
        }
    }
    
    private func presentErrorDialog(error: Error) {
            let errorAlert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(errorAlert, animated: true, completion: nil)
        }

    private func downloadAndOpenPdf(url: URL, authKey: String, pdfName: String) {
        showLoadingDialog()

        var request = URLRequest(url: url)
        request.addValue(authKey, forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.downloadTask(with: request) { [weak self] tempLocalUrl, response, error in
            DispatchQueue.main.async {
                self?.activityIndicator?.stopAnimating()
                self?.activityIndicator?.removeFromSuperview()
            }

            if let error = error {
                DispatchQueue.main.async {
                    self?.showErrorDialog(message: "Failed to download PDF: \(error.localizedDescription)")
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                    self?.showErrorDialog(message: "Download failed with HTTP status code: \(statusCode)")
                }
                return
            }

            guard let tempLocalUrl = tempLocalUrl else {
                DispatchQueue.main.async {
                    self?.showErrorDialog(message: "PDF content was empty.")
                }
                return
            }

            do {
                let documentsURL = FileManager.default.temporaryDirectory
                let destinationURL = documentsURL.appendingPathComponent(pdfName)

                // If file already exists, remove it
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }

                try FileManager.default.moveItem(at: tempLocalUrl, to: destinationURL)

                DispatchQueue.main.async {
                    self?.openPdfFile(fileURL: destinationURL)
                }
            } catch {
                DispatchQueue.main.async {
                    self?.showErrorDialog(message: "Failed to save PDF: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }

    private func openPdfFile(fileURL: URL) {
        documentInteractionController = UIDocumentInteractionController(url: fileURL)
        documentInteractionController?.delegate = self
        // Present options to open the PDF
        if !(documentInteractionController?.presentOptionsMenu(from: view.bounds, in: view, animated: true) ?? false) {
            showErrorDialog(message: "No app found to open PDF.")
        }
    }

    private func showLoadingDialog() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator?.center = view.center
        activityIndicator?.hidesWhenStopped = true
        view.addSubview(activityIndicator!)
        activityIndicator?.startAnimating()
    }

    private func showErrorDialog(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    override func onFinishLoadingWebView() {
        activityIndicator?.stopAnimating()
        activityIndicator?.removeFromSuperview()
    }

    override func goBack() {
        self.cleanAllCookies()
        self.dismiss(animated: true, completion: nil)
    }
}
