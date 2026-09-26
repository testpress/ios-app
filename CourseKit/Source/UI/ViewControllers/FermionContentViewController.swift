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
    private var heightConstraint: NSLayoutConstraint?
    private var bottomConstraint: NSLayoutConstraint?

    var isLive: Bool {
        return content?.liveStream?.isRunning == true || content?.liveStream?.isNotStarted == true
    }

    override func getParentView() -> UIView {
        if playerContainer == nil {
            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.clipsToBounds = true
            view.addSubview(container)

            heightConstraint = container.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3)
            bottomConstraint = container.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)

            NSLayoutConstraint.activate([
                container.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                container.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                isLive ? bottomConstraint! : heightConstraint!
            ])
            playerContainer = container
        }
        return playerContainer
    }

    private func applyContainerHeightConstraint() {
        heightConstraint?.isActive = !isLive
        bottomConstraint?.isActive = isLive
        view.layoutIfNeeded()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        shouldOpenLinksWithinWebview = true
        webViewDelegate = self
        emptyView = EmptyView.getInstance(parentView: webView)

        if isLive {
            AVCaptureDevice.requestAccess(for: .video) { _ in }
            AVCaptureDevice.requestAccess(for: .audio) { _ in }
            let session = AVAudioSession.sharedInstance()
            try? session.setCategory(.playAndRecord, mode: .videoChat, options: [.defaultToSpeaker, .allowBluetooth])
            try? session.setActive(true)
        }
        loadFermionStream()
    }

    override func initWebView() {
        let config = WKWebViewConfiguration()
        config.applicationNameForUserAgent = "TestpressiOSApp/WebView"
        config.preferences.javaScriptEnabled = true
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        webView = WKWebView(frame: parentView.bounds, configuration: config)
        webView.uiDelegate = self
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never

        #if DEBUG
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
        #endif
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if webView == nil {
            initWebView()
            webView.navigationDelegate = self
            webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            parentView.addSubview(webView)
            emptyView = EmptyView.getInstance(parentView: webView)
            loadFermionStream()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if view.window == nil {
            webView?.stopLoading()
            webView?.removeFromSuperview()
            emptyView?.removeFromSuperview()
            emptyView?.parentView = nil
            webView = nil
        }
    }

    deinit {
        emptyView?.parentView = nil
        emptyView?.removeFromSuperview()
    }

    func loadFermionStream() {
        if let request = buildAuthenticatedRequest() {
            emptyView.hide()
            activityIndicator.startAnimating()
            webView.load(request)
        } else {
            refreshContentAndLoad()
        }
    }

    func buildAuthenticatedRequest() -> URLRequest? {
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
                self.applyContainerHeightConstraint()
            }
            if let request = self.buildAuthenticatedRequest() {
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
}

extension FermionContentViewController: WKWebViewDelegate {
    func onFinishLoadingWebView() {
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
