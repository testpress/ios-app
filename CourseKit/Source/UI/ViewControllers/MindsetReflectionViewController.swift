//
//  MindsetReflectionViewController.swift
//  CourseKit
//

import UIKit
import WebKit

class MindsetReflectionViewController: WebViewController, WKScriptMessageHandler {

    var onReflectionSubmitted: (() -> Void)?
    var onReflectionSkipped: (() -> Void)?
    var submissionMandatory: Bool = false
    
    override func viewDidLoad() {
        self.useSSOLogin = true
        self.displayNavbar = true
        self.title = Strings.MINDSET_REFLECTION
        super.viewDidLoad()
        
        if submissionMandatory {
            self.backButton.isHidden = true
            self.navItem?.leftBarButtonItem = nil
            self.navItem?.hidesBackButton = true
        }
    }
    
    override func initWebView() {
        let contentController = WKUserContentController()
        contentController.add(WeakScriptMessageHandler(delegate: self), name: "onReflectionSubmitted")
        contentController.add(WeakScriptMessageHandler(delegate: self), name: "onReflectionSkipped")
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        if #available(iOS 14.0, *) {
            config.defaultWebpagePreferences.allowsContentJavaScript = true
        } else {
            config.preferences.javaScriptEnabled = true
        }
        
        webView = WKWebView(frame: parentView.bounds, configuration: config)
        webView.customUserAgent = "TestpressiOSApp/WebView"
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "onReflectionSubmitted" {
            self.cleanAllCookies()
            self.dismiss(animated: true) {
                self.onReflectionSubmitted?()
            }
        } else if message.name == "onReflectionSkipped" {
            guard !submissionMandatory else { return }
            self.cleanAllCookies()
            self.dismiss(animated: true) {
                self.onReflectionSkipped?()
            }
        }
    }

    override func showErrorMessage(error: TPError) {
        super.showErrorMessage(error: error)
        if submissionMandatory {
            showFailureCloseButton()
            let previousRetryHandler = emptyView.retryHandler
            emptyView.retryHandler = { [weak self] in
                if self?.submissionMandatory == true {
                    self?.navItem?.leftBarButtonItem = nil
                }
                previousRetryHandler?()
            }
        }
    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        handleLoadFailure(error: error)
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        handleLoadFailure(error: error)
    }

    private func handleLoadFailure(error: Error) {
        activityIndicator?.stopAnimating()
        let tpError = TPError(kind: .network, message: error.localizedDescription)
        let (image, title, description) = tpError.getDisplayInfo()
        self.emptyView.show(
            image: image,
            title: title,
            description: description,
            retryButtonText: Strings.TRY_AGAIN,
            retryHandler: { [weak self] in
                self?.emptyView.hide()
                if self?.submissionMandatory == true {
                    self?.navItem?.leftBarButtonItem = nil
                }
                self?.fetchSSOURLAndLoadPage()
            }
        )
        if submissionMandatory {
            showFailureCloseButton()
        }
    }

    private func showFailureCloseButton() {
        let closeButton = UIBarButtonItem(title: Strings.CANCEL, style: .plain, target: self, action: #selector(closeOnFailure))
        closeButton.tintColor = .white
        navItem?.leftBarButtonItem = closeButton
    }

    @objc private func closeOnFailure() {
        cleanAllCookies()
        dismiss(animated: true, completion: nil)
    }

    deinit {
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: "onReflectionSubmitted")
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: "onReflectionSkipped")
    }
}

private class WeakScriptMessageHandler: NSObject, WKScriptMessageHandler {
    private weak var delegate: WKScriptMessageHandler?

    init(delegate: WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        delegate?.userContentController(userContentController, didReceive: message)
    }
}
