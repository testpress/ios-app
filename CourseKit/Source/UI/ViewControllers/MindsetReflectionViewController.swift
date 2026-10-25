//
//  MindsetReflectionViewController.swift
//  CourseKit
//

import UIKit
import WebKit

class MindsetReflectionViewController: WebViewController, WKScriptMessageHandler {

    var onReflectionSubmitted: (() -> Void)?
    var onReflectionSkipped: (() -> Void)?
    var onBackButtonPressed: (() -> Void)?
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
        
        let skipScript = """
        document.addEventListener('click', function(e) {
            var target = e.target.closest('button');
            if (target) {
                var text = (target.innerText || target.textContent || '').toLowerCase();
                if (text.includes('skip') || text.includes("i'll do later") || target.getAttribute('aria-label') === 'Close') {
                    if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.onReflectionSkipped) {
                        window.webkit.messageHandlers.onReflectionSkipped.postMessage('');
                    }
                }
            }
        }, true);
        """
        let userScript = WKUserScript(source: skipScript, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        contentController.addUserScript(userScript)

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

    open override func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            let path = url.path
            if path.contains("/exams/review/") || path.contains("/attempt_answers") || path.contains("/mindset_insights/") {
                decisionHandler(.cancel)
                self.cleanAllCookies()
                self.dismiss(animated: true) {
                    self.onReflectionSubmitted?()
                }
                return
            }
        }
        super.webView(webView, decidePolicyFor: navigationAction, decisionHandler: decisionHandler)
    }

    @objc open override func goBack() {
        if (useWebviewNavigation && webView.canGoBack) {
            webView.goBack()
        } else {
            self.cleanAllCookies()
            self.dismiss(animated: true) {
                self.onBackButtonPressed?()
            }
        }
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
        showErrorMessage(error: TPError(message: error.localizedDescription, kind: .network))
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showErrorMessage(error: TPError(message: error.localizedDescription, kind: .network))
    }

    private func showFailureCloseButton() {
        let closeButton = UIBarButtonItem(title: Strings.CANCEL, style: .plain, target: self, action: #selector(closeOnFailure))
        closeButton.tintColor = self.navigationController?.navigationBar.tintColor ?? .white
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
