//
//  WebViewController.swift
//  ios-app
//
//  Created by Karthik on 17/03/19.
//  Copyright © 2019 Testpress. All rights reserved.
//

import TTGSnackbar
import UIKit
import WebKit
import Alamofire

class WebViewController: BaseWebViewController, WKWebViewDelegate, WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
    }
    
    var emptyView: EmptyView!
    var url: String = ""
    var loading: Bool = false
    var navBar: UINavigationBar?
    var use_sso_login: Bool = false
    
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
        self.emptyView = EmptyView.getInstance(parentView: view)
    
        if (use_sso_login) {
            self.sso_login();
        }
        else {
            self.loadWebView()
        }
        self.showNavbar()
        
        activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y - getNavBarHeight())
        activityIndicator?.startAnimating()
    }
    
    func showNavbar() {
        let screenSize: CGRect = UIScreen.main.bounds
        navBar = UINavigationBar(frame: CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: screenSize.width, height: getNavBarHeight()))
        let navItem = UINavigationItem(title: Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String);
        navItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.goBack))
        navBar!.setItems([navItem], animated: false);
        self.view.addSubview(navBar!);
        
        navBar!.translatesAutoresizingMaskIntoConstraints = false
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 11.0, *) {
            navBar!.topAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.topAnchor
                ).isActive = true
        } else {
            navBar!.topAnchor.constraint(
                equalTo: topLayoutGuide.bottomAnchor
                ).isActive = true
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
        let nextViewController = MainViewController()
        self.present(nextViewController, animated:false, completion:nil)
    }
    
    func loadWebView() {
        self.emptyView.hide()
        let url = URL(string: self.url)!
        webView.load(URLRequest(url: url))
    }
    
    func sso_login() {
        activityIndicator?.startAnimating()
        self.removeCookies()
        TPApiClient.getSSOUrl(
            completion: {
                sso_detail, error in
                print("hOLA")
                if let error = error {
                    debugPrint(error.message ?? "No error")
                    debugPrint(error.kind)
                    var retryButtonText: String?
                    var retryHandler: (() -> Void)?
                    if error.kind == .network {
                        retryButtonText = Strings.TRY_AGAIN
                        retryHandler = {
                            self.emptyView.hide()
                            self.sso_login()
                        }
                    }
                    self.activityIndicator.stopAnimating()
                    let (image, title, description) = error.getDisplayInfo()
                    self.emptyView.show(image: image, title: title, description: description,
                                        retryButtonText: retryButtonText, retryHandler: retryHandler)
                    self.showNavbar()
                    return
                }
                self.url = Constants.BASE_URL + sso_detail!.url + self.url
                self.loadWebView()
                return
        }
        )
    }
    
    func removeCookies(){
        let cookieJar = HTTPCookieStorage.shared
        
        for cookie in cookieJar.cookies! {
            cookieJar.deleteCookie(cookie)
        }
    }

    override func initWebView() {
        let contentController = WKUserContentController()
        contentController.add(self, name: "callbackHandler")
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        config.preferences.javaScriptEnabled = true
        webView = WKWebView( frame: parentView.bounds, configuration: config)
    }
    func onFinishLoadingWebView() {
        activityIndicator?.stopAnimating()
    }
}
