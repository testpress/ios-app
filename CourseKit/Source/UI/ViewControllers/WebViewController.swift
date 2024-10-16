//
//  WebViewController.swift
//  ios-app
//
//  Created by Karthik raja on 6/7/19.
//  Copyright © 2019 Testpress. All rights reserved.
//

import Foundation
import TTGSnackbar
import UIKit
import WebKit

open class WebViewController: BaseWebViewController, WKWebViewDelegate {
    
    public var emptyView: EmptyView!
    public var url: String = ""
    public var request: URLRequest?
    public var loading: Bool = false
    public var navBar: UINavigationBar?
    public var useSSOLogin: Bool = false
    public var displayNavbar = true
    public var useWebviewNavigation = false
    public var backButton = UIButton(type: .system)
    public var navItem: UINavigationItem?
    public var refreshControl:UIRefreshControl?

    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            navBar?.frame.size.height = getNavBarHeight() + UIApplication.shared.statusBarFrame.size.height
        } else {
            navBar?.frame.size.width = getNavBarHeight() + UIApplication.shared.statusBarFrame.size.height
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        webViewDelegate = self
        self.emptyView = EmptyView.getInstance(parentView: view)
        initializeLoadingIndicator()
        if (displayNavbar) {
            self.showNavbar()
        }
        
        addPullToRefresh()
        
        if (useSSOLogin) {
            self.emptyView.hide()
            self.fetchSSOURLAndLoadPage();
        } else {
            self.loadWebView()
        }
    
    }

    open func initializeLoadingIndicator() {
        activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y - getNavBarHeight())
    }

    open func showLoading() {
        activityIndicator?.startAnimating()
    }
    
    open func showNavbar() {
        let screenSize: CGRect = UIScreen.main.bounds
        
        navBar = UINavigationBar(frame: CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: screenSize.width, height: getNavBarHeight()))
        let title = self.title ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String
        
        backButton.setImage(UIImage(named: "ic_navigate_before_36pt"), for: .normal)
        backButton.addTarget(self, action: #selector(self.goBack), for: .touchUpInside)
        backButton.tintColor = .white
    
        navItem = UINavigationItem(title: title);
        navItem?.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        navItem?.leftBarButtonItem?.imageInsets =  UIEdgeInsets.init(top: 5, left: 50, bottom: -5, right: 30)
        navBar!.setItems([navItem!], animated: false);
        self.view.addSubview(navBar!);
        navBar!.translatesAutoresizingMaskIntoConstraints = false
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 11.0, *) {
            navBar!.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            navBar!.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        }
        view.addConstraint(NSLayoutConstraint(item: navBar!, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: navBar!, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: webView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: webView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: webView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal, toItem: navBar, attribute: .bottom, multiplier: 1, constant: 0))
    }
    
    public func addPullToRefresh() {
        self.refreshControl = UIRefreshControl.init()
        refreshControl!.addTarget(self, action:#selector(refreshControlClicked), for: UIControl.Event.valueChanged)
        self.webView.scrollView.addSubview(self.refreshControl!)
    }
    
    @objc func refreshControlClicked(){
        webView.reload()
        refreshControl?.endRefreshing() 
    }
    
    public func getNavBarHeight() -> CGFloat {
        return UINavigationController().navigationBar.frame.size.height
    }
    
    @objc open func goBack() {
        if (useWebviewNavigation && webView.canGoBack) {
            webView.goBack()
        } else {
            self.cleanAllCookies()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    open func loadWebView() {
        showLoading()
        self.emptyView.hide()
        if let request = self.request {
            webView.load(request)
        } else {
            let url = URL(string: self.url)!
            webView.load(URLRequest(url: url))
        }
    }
    
    public func removeCookies(){
         let cookieJar = HTTPCookieStorage.shared

         for cookie in cookieJar.cookies! {
             cookieJar.deleteCookie(cookie)
         }
     }
    
    
    public func fetchSSOURLAndLoadPage() {
            activityIndicator?.startAnimating()
            self.removeCookies()
            TPApiClient.getSSOUrl(
                completion: {
                    sso_detail, error in
                                                                                                                                                   
                    if let error = error {
                        self.showErrorMessage(error: error)
                        return
                    }
                    
                    self.url = TestpressCourse.shared.baseURL + sso_detail!.url + self.url
                    self.loadWebView()
                    return
            }
            )
        }
    
    open func showErrorMessage(error: TPError) {
        debugPrint(error.message ?? "No error")
        debugPrint(error.kind)
        var retryButtonText: String?
        var retryHandler: (() -> Void)?
        if error.kind == .network {
            retryButtonText = Strings.TRY_AGAIN
            retryHandler = {
                self.emptyView.hide()
                self.fetchSSOURLAndLoadPage()
            }
        }
        self.activityIndicator.stopAnimating()
        let (image, title, description) = error.getDisplayInfo()
        self.emptyView.show(image: image, title: title, description: description,
                            retryButtonText: retryButtonText, retryHandler: retryHandler)
        if (self.displayNavbar) {
            self.showNavbar()
        }
    }
    
    open override func initWebView() {
        webView = WKWebView( frame: parentView.bounds)
    }

    public func cleanAllCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }

    open func onFinishLoadingWebView() {
        activityIndicator?.stopAnimating()
    }
}
