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

class WebViewController: BaseWebViewController, WKWebViewDelegate, WKScriptMessageHandler {
    
    var emptyView: EmptyView!
    var url: String = ""
    var loading: Bool = false
    var navBar: UINavigationBar?
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            navBar?.frame.size.height = getNavBarHeight() + UIApplication.shared.statusBarFrame.size.height
        } else {
            navBar?.frame.size.width = getNavBarHeight() + UIApplication.shared.statusBarFrame.size.height
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webViewDelegate = self
        let url = URL(string: self.url)!
        webView.load(URLRequest(url: url))
        
        let screenSize: CGRect = UIScreen.main.bounds
        activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y - getNavBarHeight())
        activityIndicator?.startAnimating()

        navBar = UINavigationBar(frame: CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: screenSize.width, height: getNavBarHeight()))
        let title = self.title ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String
        
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "ic_navigate_before_36pt"), for: .normal)
        button.addTarget(self, action: #selector(self.goBack), for: .touchUpInside)
        button.tintColor = .white
    
        let navItem = UINavigationItem(title: title);
        navItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        navItem.leftBarButtonItem?.imageInsets =  UIEdgeInsetsMake(5, 50, -5, 30)
        navBar!.setItems([navItem], animated: false);
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
    
    func getNavBarHeight() -> CGFloat {
        return UINavigationController().navigationBar.frame.size.height
    }
    
    @objc func goBack() {
        self.cleanAllCookies()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func initWebView() {
        let contentController = WKUserContentController()
        contentController.add(self, name: "callbackHandler")
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        config.preferences.javaScriptEnabled = true
        webView = WKWebView( frame: parentView.bounds, configuration: config)
    }

    func cleanAllCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }

    func onFinishLoadingWebView() {
        activityIndicator?.stopAnimating()
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    }
    
}
