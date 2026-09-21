//
//  FermionContentViewController.swift
//  CourseKit
//
//  Renders a Fermion live stream (`fermion_url` from `GET /api/v2.4/contents/<id>/`)
//  inside a WKWebView with auth + device headers.
//

import UIKit
import WebKit

class FermionContentViewController: BaseWebViewController {

    var content: Content!
    var viewModel: ChapterContentDetailViewModel?

    private var emptyView: EmptyView!
    private var isFetchingContent = false

    override func viewDidLoad() {
        super.viewDidLoad()
        shouldOpenLinksWithinWebview = true
        webViewDelegate = self
        emptyView = EmptyView.getInstance(parentView: webView)
        loadFermionStream()
    }

    override func initWebView() {
        // WebRTC-capable config: Fermion live calls need JS + inline media
        // with no user-action gate for playback.
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        webView = WKWebView(frame: parentView.bounds, configuration: config)
        webView.customUserAgent = "TestpressiOSApp/WebView"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if webView == nil {
            recreateWebView()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tearDownWebView()
    }

    private func tearDownWebView() {
        webView?.stopLoading()
        webView?.removeFromSuperview()
        emptyView.removeFromSuperview()
        emptyView.parentView = nil
        webView = nil
    }

    private func recreateWebView() {
        initWebView()
        webView.navigationDelegate = self
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        parentView.addSubview(webView)
        if activityIndicator.superview != nil {
            parentView.bringSubviewToFront(activityIndicator)
        }
        emptyView = EmptyView.getInstance(parentView: webView)
        loadFermionStream()
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
        let embedURL = content.liveStream?.streamURL.trimmingCharacters(in: .whitespacesAndNewlines)
        let urlString = (embedURL.flatMap { $0.isEmpty ? nil : $0 })
            ?? content.fermionURL?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let urlString = urlString, !urlString.isEmpty, let url = URL(string: urlString) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("JWT \(KeychainTokenItem.getToken())", forHTTPHeaderField: "Authorization")
        request.addDeviceHeaders()
        return request
    }

    private func refreshContentAndLoad() {
        guard !isFetchingContent else { return }
        isFetchingContent = true
        activityIndicator.startAnimating()
        Content.fetchContent(url: content.getUrl()) { [weak self] content, error in
            guard let self = self else { return }
            self.isFetchingContent = false
            guard webView != nil else { return }
            self.activityIndicator.stopAnimating()
            if let content = content {
                DBManager<Content>().addData(object: content)
                self.content = content
            }
            if let request = self.buildAuthenticatedRequest() {
                self.emptyView.hide()
                self.activityIndicator.startAnimating()
                self.webView.load(request)
            } else {
                self.showLoadingError(error: error)
            }
        }
    }

    private func showLoadingError(error: TPError?) {
        if let error = error {
            debugPrint(error.message ?? "No error")
            debugPrint(error.kind)
        }
        var retryHandler: (() -> Void)?
        if error == nil || error?.kind == .network {
            retryHandler = { [weak self] in
                self?.emptyView.hide()
                self?.loadFermionStream()
            }
        }
        if let error = error {
            let (image, title, description) = error.getDisplayInfo()
            emptyView.show(image: image, title: title, description: description,
                           retryButtonText: Strings.TRY_AGAIN, retryHandler: retryHandler)
        } else {
            emptyView.show(image: Images.TestpressAlertWarning.image,
                           title: Strings.LOADING_FAILED,
                           description: Strings.SOMETHIGN_WENT_WRONG,
                           retryButtonText: Strings.TRY_AGAIN, retryHandler: retryHandler)
        }
    }
}

extension FermionContentViewController: WKWebViewDelegate {
    func onFinishLoadingWebView() {
        viewModel?.createContentAttempt()
    }
}
