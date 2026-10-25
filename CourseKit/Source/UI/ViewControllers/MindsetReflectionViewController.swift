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
            applyMandatoryNavbarState()
        }
    }
    
    override func initWebView() {
        let contentController = WKUserContentController()
        contentController.add(WeakScriptMessageHandler(delegate: self), name: "onReflectionSubmitted")
        contentController.add(WeakScriptMessageHandler(delegate: self), name: "onReflectionSkipped")
        
        let skipScript = """
        document.addEventListener('click', function(e) {
            var button = e.target.closest('button');
            if (!button) return;
            var clickAttr = button.getAttribute('@click') || '';
            var xShowAttr = button.getAttribute('x-show') || '';
            var actionAttr = button.getAttribute('data-action') || '';
            if (clickAttr.indexOf('handleCloseOrSkip') !== -1 || xShowAttr.indexOf('postExamReflectionMandatory') !== -1 || actionAttr === 'skip') {
                if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.onReflectionSkipped) {
                    window.webkit.messageHandlers.onReflectionSkipped.postMessage('');
                }
            }
        }, true);
        """
        let userScript = WKUserScript(source: skipScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
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
        guard navigationAction.targetFrame?.isMainFrame == true, let url = navigationAction.request.url else {
            super.webView(webView, decidePolicyFor: navigationAction, decisionHandler: decisionHandler)
            return
        }

        let path = url.path
        if path.hasPrefix("/exams/review/") || path.hasPrefix("/exams/review_attempt_answers") || path.hasPrefix("/review_attempt_answers") {
            decisionHandler(.cancel)
            finish(onReflectionSubmitted)
            return
        }

        super.webView(webView, decidePolicyFor: navigationAction, decisionHandler: decisionHandler)
    }

    @objc open override func goBack() {
        if useWebviewNavigation && webView.canGoBack {
            webView.goBack()
            return
        }
        guard !submissionMandatory else { return }
        finish(onBackButtonPressed)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "onReflectionSubmitted" {
            finish(onReflectionSubmitted)
        } else if message.name == "onReflectionSkipped" {
            guard !submissionMandatory else { return }
            finish(onReflectionSkipped)
        }
    }

    override func showErrorMessage(error: TPError) {
        super.showErrorMessage(error: error)
        if submissionMandatory {
            applyMandatoryNavbarState()
        }
    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showErrorMessage(error: TPError(message: error.localizedDescription, kind: .network))
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showErrorMessage(error: TPError(message: error.localizedDescription, kind: .network))
    }

    private func applyMandatoryNavbarState() {
        backButton.isHidden = true
        navItem?.leftBarButtonItem = nil
        navItem?.hidesBackButton = true
    }

    private func finish(_ callback: (() -> Void)? = nil) {
        cleanAllCookies()
        dismiss(animated: true) {
            callback?()
        }
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
