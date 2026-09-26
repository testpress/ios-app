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

    private var emptyView: EmptyView!
    private var isFetchingContent = false
    private var playerContainer: UIView!

    var isLive: Bool {
        return true
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

        AVCaptureDevice.requestAccess(for: .video) { _ in }
        AVCaptureDevice.requestAccess(for: .audio) { _ in }
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .videoChat, options: [.defaultToSpeaker, .allowBluetooth])
        try? session.setActive(true)
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

    deinit {
        webView?.stopLoading()
        webView?.navigationDelegate = nil
        webView?.uiDelegate = nil
        webView?.removeFromSuperview()
        emptyView?.parentView = nil
        emptyView?.removeFromSuperview()
    }

    func loadFermionStream() {
        if let request = buildStreamRequest() {
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
                setTimeout(function() { window.dispatchEvent(new Event('resize')); }, 100);
                setTimeout(function() { window.dispatchEvent(new Event('resize')); }, 300);
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
                    v.removeEventListener('webkitendfullscreen', triggerResize);
                    v.addEventListener('webkitendfullscreen', triggerResize);
                    v.removeEventListener('webkitpresentationmodechanged', triggerResize);
                    v.addEventListener('webkitpresentationmodechanged', triggerResize);
                });
            }
            setupVideos();
            var observer = new MutationObserver(setupVideos);
            if (document.documentElement) {
                observer.observe(document.documentElement, { childList: true, subtree: true });
            }
        })();
    """
}

extension FermionContentViewController: WKWebViewDelegate {
    func onFinishLoadingWebView() {
        evaluateJavaScript(FermionContentViewController.VIEWPORT_FIT_SCRIPT)
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
}
