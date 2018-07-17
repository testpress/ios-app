//
//  InAppBrowserViewController.swift
//  ios-app
//
//  Copyright © 2017 Testpress. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

class InAppBrowserViewController: UIViewController {

    @IBOutlet weak var navigationBarItem: UINavigationItem!
    @IBOutlet weak var containerView: UIView!
    
    var url: String!
    var webView: UIWebView!
    var activityIndicator: UIActivityIndicatorView!
    var emptyView: EmptyView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBarItem.title = title
        webView = UIWebView(frame: containerView.bounds)
        webView.delegate = self
        webView.scalesPageToFit = true
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(webView)
        activityIndicator = UIUtils.initActivityIndicator(parentView: containerView)
        activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y - 50)
        emptyView = EmptyView.getInstance(parentView: containerView)
        
        let request = URLRequest(url: URL(string: url)!)
        webView.loadRequest(request)
    }
    
    @IBAction func back() {
        if webView.canGoBack {
            if webView.isLoading {
                webView.stopLoading()
            } else {
                webView.goBack()
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.stopLoading()
    }

}

extension InAppBrowserViewController: UIWebViewDelegate {
    
    func loadCookies() {
        guard let cookies = UserDefaults.standard.value(forKey: "cookies") as? [[HTTPCookiePropertyKey: Any]] else {
            return
        }
        cookies.forEach { (cookie) in
            guard let cookie = HTTPCookie.init(properties: cookie) else {
                return
            }
            HTTPCookieStorage.shared.setCookie(cookie)
        }
    }
    
    func saveCookies() {
        guard let cookies = HTTPCookieStorage.shared.cookies else {
            return
        }
        let array = cookies.compactMap { (cookie) -> [HTTPCookiePropertyKey: Any]? in
            cookie.properties
        }
        UserDefaults.standard.set(array, forKey: "cookies")
        UserDefaults.standard.synchronize()
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        activityIndicator.startAnimating()
        loadCookies()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        saveCookies()
        activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        activityIndicator.stopAnimating()
        if error._code != NSURLErrorCancelled {
            let retryHandler = {
                self.emptyView.hide()
                let request = URLRequest(url: URL(string: self.url)!)
                webView.loadRequest(request)
            }
            emptyView.show(image: Images.TestpressNoWifi.image, title: Strings.NETWORK_ERROR,
                           description: error.localizedDescription, retryHandler: retryHandler)
        }
    }
}
