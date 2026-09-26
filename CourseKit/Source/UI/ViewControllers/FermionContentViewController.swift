//
//  FermionContentViewController.swift
//  CourseKit
//
//  Copyright © 2024 Testpress. All rights reserved.
//

import UIKit
import WebKit
import AVFoundation

class FermionContentViewController: BaseWebViewController {

    var content: Content!
    var viewModel: ChapterContentDetailViewModel?

    private var initialLoadComplete = false
    private var initialStreamUrl: URL?

    private var emptyView: EmptyView!
    private var isFetchingContent = false
    private var playerContainer: UIView!

    var isLive: Bool {
        return content?.liveStream?.isRunning == true || content?.liveStream?.isNotStarted == true
    }

    override func getParentView() -> UIView {
        if playerContainer == nil {
            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.clipsToBounds = true
            container.backgroundColor = .black
            view.backgroundColor = .black
            view.addSubview(container)

            NSLayoutConstraint.activate([
                container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                container.topAnchor.constraint(equalTo: view.topAnchor),
                container.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            playerContainer = container
        }
        return playerContainer
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        shouldOpenLinksWithinWebview = true
        webViewDelegate = self
        emptyView = EmptyView.getInstance(parentView: webView)

        if let playerContainer = playerContainer, let webView = webView {
            webView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                webView.leadingAnchor.constraint(equalTo: playerContainer.leadingAnchor),
                webView.trailingAnchor.constraint(equalTo: playerContainer.trailingAnchor),
                webView.topAnchor.constraint(equalTo: playerContainer.topAnchor),
                webView.bottomAnchor.constraint(equalTo: playerContainer.bottomAnchor)
            ])
        }

        if isLive {
            AVCaptureDevice.requestAccess(for: .video) { _ in }
            AVCaptureDevice.requestAccess(for: .audio) { _ in }
            let session = AVAudioSession.sharedInstance()
            try? session.setCategory(.playAndRecord, mode: .videoChat, options: [.defaultToSpeaker, .allowBluetooth])
            try? session.setActive(true)
        }
        loadFermionStream()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            self?.webView?.evaluateJavaScript("window.dispatchEvent(new Event('resize'));", completionHandler: nil)
        }
    }

    override func initWebView() {
        let config = WKWebViewConfiguration()
        config.applicationNameForUserAgent = "TestpressiOSApp/WebView"
        config.preferences.javaScriptEnabled = true
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        if #available(iOS 15.4, *) {
            config.preferences.isElementFullscreenEnabled = true
        }

        let userScript = WKUserScript(
            source: FermionContentViewController.VIEWPORT_FIT_SCRIPT,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        config.userContentController.addUserScript(userScript)
        config.userContentController.add(WeakScriptMessageHandler(self), name: "liveEndHandler")

        webView = WKWebView(frame: parentView.bounds, configuration: config)
        webView.uiDelegate = self
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never

        #if DEBUG
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
        #endif
    }

    private var isCleanedUp = false

    func cleanUp() {
        guard !isCleanedUp else { return }
        isCleanedUp = true

        let stopMediaScript = """
            (function() {
                try {
                    if (window.localStream) {
                        window.localStream.getTracks().forEach(function(track) { track.stop(); });
                    }
                    var mediaElements = document.querySelectorAll('video, audio');
                    mediaElements.forEach(function(m) {
                        try {
                            if (m.srcObject) {
                                m.srcObject.getTracks().forEach(function(t) { t.stop(); });
                                m.srcObject = null;
                            }
                            m.pause();
                            m.src = '';
                        } catch(e) {}
                    });
                } catch(e) {}
            })();
        """
        webView?.evaluateJavaScript(stopMediaScript, completionHandler: nil)

        webView?.stopLoading()
        if let blankUrl = URL(string: "about:blank") {
            webView?.load(URLRequest(url: blankUrl))
        }

        webView?.configuration.userContentController.removeScriptMessageHandler(forName: "liveEndHandler")
        webView?.navigationDelegate = nil
        webView?.uiDelegate = nil
        webView?.removeFromSuperview()
        emptyView?.parentView = nil
        emptyView?.removeFromSuperview()
        webView = nil

        if isLive {
            let session = AVAudioSession.sharedInstance()
            try? session.setActive(false, options: .notifyOthersOnDeactivation)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isBeingDismissed || isMovingFromParent || parent == nil || view.window == nil {
            cleanUp()
        }
    }

    deinit {
        cleanUp()
    }

    func returnToApp() {
        cleanUp()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let contentDetailPageVC = self.findParentContentDetailPageViewController() {
                contentDetailPageVC.back()
            } else if let nav = self.navigationController {
                nav.popViewController(animated: true)
            } else if let presentingVC = self.presentingViewController {
                presentingVC.dismiss(animated: true)
            } else {
                self.dismiss(animated: true)
            }
        }
    }

    private func findParentContentDetailPageViewController() -> ContentDetailPageViewController? {
        if let parent = self.parent as? ContentDetailPageViewController {
            return parent
        }
        if let grandParent = self.parent?.parent as? ContentDetailPageViewController {
            return grandParent
        }
        var responder: UIResponder? = self
        while let next = responder?.next {
            if let vc = next as? ContentDetailPageViewController {
                return vc
            }
            responder = next
        }
        return nil
    }

    func loadFermionStream() {
        if let request = buildStreamRequest() {
            initialLoadComplete = false
            emptyView.hide()
            activityIndicator.startAnimating()
            webView.load(request)
        } else {
            refreshContentAndLoad()
        }
    }

    func buildStreamRequest() -> URLRequest? {
        guard let streamUrl = content.liveStream?.streamURL.trimmingCharacters(in: .whitespacesAndNewlines),
              !streamUrl.isEmpty,
              let url = URL(string: streamUrl) else {
            return nil
        }
        initialStreamUrl = url
        return URLRequest(url: url)
    }

    private func refreshContentAndLoad() {
        guard !isFetchingContent else { return }
        isFetchingContent = true
        activityIndicator.startAnimating()
        Content.fetchContent(url: content.getUrl()) { [weak self] content, error in
            guard let self = self else { return }
            self.isFetchingContent = false
            self.activityIndicator.stopAnimating()
            if let content = content {
                DBManager<Content>().addData(object: content)
                self.content = content
            }
            if let request = self.buildStreamRequest() {
                self.initialLoadComplete = false
                self.emptyView.hide()
                self.activityIndicator.startAnimating()
                self.webView.load(request)
            } else {
                let (image, title, description) = (error ?? TPError(kind: .network)).getDisplayInfo()
                self.emptyView.show(image: image, title: title, description: description, retryButtonText: Strings.TRY_AGAIN) { [weak self] in
                    self?.loadFermionStream()
                }
            }
        }
    }

    private static let VIEWPORT_FIT_SCRIPT = """
        (function() {
            if (window.__fermionViewportFitInjected) return;
            window.__fermionViewportFitInjected = true;

            var meta = document.querySelector('meta[name="viewport"]');
            if (!meta) {
                meta = document.createElement('meta');
                meta.name = 'viewport';
                document.head.appendChild(meta);
            }
            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover';
            document.documentElement.style.cssText += 'width:100%!important;height:100%!important;overflow:hidden!important;';
            document.body.style.cssText += 'width:100%!important;height:100%!important;overflow:hidden!important;margin:0!important;padding:0!important;';

            function triggerResize() {
                window.dispatchEvent(new Event('resize'));
            }

            document.addEventListener('fullscreenchange', triggerResize);
            document.addEventListener('webkitfullscreenchange', triggerResize);
            document.addEventListener('webkitendfullscreen', triggerResize, true);

            function setupVideos() {
                var videos = document.querySelectorAll('video');
                videos.forEach(function(v) {
                    if (!v.hasAttribute('playsinline')) {
                        v.setAttribute('playsinline', '');
                        v.setAttribute('webkit-playsinline', '');
                    }
                });
            }
            setupVideos();
            var observer = new MutationObserver(setupVideos);
            if (document.documentElement) {
                observer.observe(document.documentElement, { childList: true, subtree: true });
            }

            function notifyEnd() {
                try {
                    if (window.localStream) {
                        window.localStream.getTracks().forEach(function(track) { track.stop(); });
                    }
                    var mediaElements = document.querySelectorAll('video, audio');
                    mediaElements.forEach(function(m) {
                        try {
                            if (m.srcObject) {
                                m.srcObject.getTracks().forEach(function(t) { t.stop(); });
                                m.srcObject = null;
                            }
                            m.pause();
                            m.src = '';
                        } catch(e) {}
                    });
                } catch(e) {}
                try {
                    window.webkit.messageHandlers.liveEndHandler.postMessage('ended');
                } catch(e) {}
            }

            // Window close hook
            var origClose = window.close;
            window.close = function() {
                notifyEnd();
                if (origClose) {
                    try { origClose.apply(window, arguments); } catch(e) {}
                }
            };

            // URL navigation tracking matching Android shouldOverrideUrlLoading
            var initialPath = window.location.pathname;
            var initialHost = window.location.host;

            function checkUrlChange() {
                if (window.location.host !== initialHost || window.location.pathname !== initialPath) {
                    notifyEnd();
                }
            }

            var originalPushState = history.pushState;
            history.pushState = function() {
                originalPushState.apply(this, arguments);
                checkUrlChange();
            };

            var originalReplaceState = history.replaceState;
            history.replaceState = function() {
                originalReplaceState.apply(this, arguments);
                checkUrlChange();
            };

            window.addEventListener('popstate', checkUrlChange);
            window.addEventListener('hashchange', checkUrlChange);
            window.addEventListener('beforeunload', notifyEnd);
            window.addEventListener('pagehide', notifyEnd);

            window.addEventListener('message', function(event) {
                if (event && event.data) {
                    var msg = typeof event.data === 'string' ? event.data : (event.data.type || event.data.action || event.data.event || '');
                    if (/end|leave|exit|close|finish|complete/i.test(msg)) {
                        notifyEnd();
                    }
                }
            });
        })();
    """
}

extension FermionContentViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "liveEndHandler" {
            returnToApp()
        }
    }
}

private class WeakScriptMessageHandler: NSObject, WKScriptMessageHandler {
    weak var delegate: WKScriptMessageHandler?
    init(_ delegate: WKScriptMessageHandler) {
        self.delegate = delegate
    }
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        delegate?.userContentController(userContentController, didReceive: message)
    }
}

extension FermionContentViewController: WKWebViewDelegate {
    func onFinishLoadingWebView() {
        initialLoadComplete = true
        viewModel?.createContentAttempt()
    }
}

extension FermionContentViewController: WKUIDelegate {
    @available(iOS 15.0, *)
    func webView(_ webView: WKWebView,
                 requestMediaCapturePermissionFor origin: WKSecurityOrigin,
                 initiatedByFrame frame: WKFrameInfo,
                 type: WKMediaCaptureType,
                 decisionHandler: @escaping (WKPermissionDecision) -> Void) {
        decisionHandler(.grant)
    }

    func webViewDidClose(_ webView: WKWebView) {
        returnToApp()
    }

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let requestUrl = navigationAction.request.url {
            if handleNavigation(url: requestUrl) {
                return nil
            }
            webView.load(navigationAction.request)
        }
        return nil
    }

    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let lowerMessage = message.lowercased()
        if lowerMessage.contains("leave") || lowerMessage.contains("end") || lowerMessage.contains("exit") || lowerMessage.contains("close") {
            returnToApp()
        }
        completionHandler(true)
    }

    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}

extension FermionContentViewController {
    private func handleNavigation(url: URL) -> Bool {
        guard initialLoadComplete, let currentUri = initialStreamUrl else {
            return false
        }

        let isSameHost = currentUri.host?.caseInsensitiveCompare(url.host ?? "") == .orderedSame
        let currentPath = currentUri.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let newPath = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let isSamePath = currentPath == newPath
        let isSamePage = isSameHost && isSamePath

        if !isSamePage && url.absoluteString != "about:blank" {
            returnToApp()
            return true
        }
        return false
    }

    override func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                          decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let requestUrl = navigationAction.request.url {
            if handleNavigation(url: requestUrl) {
                decisionHandler(.cancel)
                return
            }
        }
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse,
                        decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let responseUrl = navigationResponse.response.url {
            if handleNavigation(url: responseUrl) {
                decisionHandler(.cancel)
                return
            }
        }
        decisionHandler(.allow)
    }

    public func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        if let currentUrl = webView.url {
            _ = handleNavigation(url: currentUrl)
        }
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()
    }
}
