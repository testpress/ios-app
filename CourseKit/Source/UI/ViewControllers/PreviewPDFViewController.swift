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
    
    deinit {
        (webView.configuration.userContentController).removeScriptMessageHandler(forName: "openPdf")
    }
}
