import Foundation
import WebKit
import CourseKit

class UserDataFormViewController: WebViewController, WKScriptMessageHandler {

    init() {
        super.init(nibName: nil, bundle: nil)
        self.useSSOLogin = true 
        self.url = "&next=/settings/force/mobile/"
        self.title = "Update Profile"
        self.displayNavbar = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStatusBarColor()
    }
    
    override func initWebView() {
        let contentController = WKUserContentController()
        contentController.add(self, name: "onSubmit")
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        config.preferences.javaScriptEnabled = true
        webView = WKWebView(frame: parentView.bounds, configuration: config)
        webView.customUserAgent = "TestpressiOSApp/WebView"
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "onSubmit" else { return }
        
        self.emptyView.hide()
        self.cleanAllCookies()
        
        let storyboard = UIStoryboard(name: Constants.MAIN_STORYBOARD, bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: Constants.TAB_VIEW_CONTROLLER
        )

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let window = appDelegate.window else {
            return
        }
        
        window.rootViewController = viewController
        Toast.shared.show(message: "Profile updated successfully")
    }

    override func onFinishLoadingWebView() {
        activityIndicator?.stopAnimating()
    }

    override func goBack() {
        self.cleanAllCookies()
        self.dismiss(animated: true, completion: nil)
    }
}
