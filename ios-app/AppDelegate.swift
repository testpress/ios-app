//
//  AppDelegate.swift
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

import FBSDKCoreKit
import IQKeyboardManagerSwift
import UIKit
import Sentry


import Alamofire
import UserNotifications
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import AVKit
import CourseKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    var window: UIWindow?
    
    var activityIndicator: UIActivityIndicatorView!
    var emptyView: EmptyView!
    var blurEffectView: UIVisualEffectView?
    
    
    func application(_ application: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        
        return ApplicationDelegate.shared.application(application, open: url, options: options)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        TestpressCourse.shared.initialize(subdomain: AppConstants.SUBDOMAIN, primaryColor: AppConstants.PRIMARY_COLOR)
        registerForNotifications(application)
        configureFirebase()
        customizeAppearance()
        configureAudioSession()
        initializeFacebook(application, launchOptions: launchOptions)
        configureKeyboardManager()
        handleFirstLaunch()
        setupRootViewController()
        setupAuthErrorHandlerOnApiClient()
        
        InstituteRepository.shared.getSettings { instituteSettings, error in
            if let instituteSettings = instituteSettings {
                self.setupSentry(instituteSettings: instituteSettings)
                self.restrictScreenRecording(instituteSettings: instituteSettings)
            }
        }

        return true
    }

    private func registerForNotifications(_ application: UIApplication) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { _, _ in })
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
    }

    private func configureFirebase() {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
    }

    private func customizeAppearance() {
        let navBarAppearance = UINavigationBar.appearance()
        navBarAppearance.isTranslucent = false
        navBarAppearance.backgroundColor = TestpressCourse.shared.primaryColor
        navBarAppearance.barTintColor = TestpressCourse.shared.primaryColor
        UIBarButtonItem.appearance().tintColor = Colors.getRGB(Colors.PRIMARY_TEXT)
        navBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Colors.getRGB(Colors.PRIMARY_TEXT)]

        if !UIUtils.isiPad() {
            UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -5)
        }
    }

    private func configureAudioSession() {
        do {
            if #available(iOS 10.0, *) {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            }
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
    }

    private func initializeFacebook(_ application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func configureKeyboardManager() {
        IQKeyboardManager.shared.enable = true
    }

    private func handleFirstLaunch() {
        let userDefaults = UserDefaults.standard
        if userDefaults.bool(forKey: Constants.LAUNCHED_APP_BEFORE) == false {
            KeychainTokenItem.clearKeychainItems()
            userDefaults.set(true, forKey: Constants.LAUNCHED_APP_BEFORE)
            userDefaults.synchronize()
        }
    }

    private func setupRootViewController() {
        let viewController = MainViewController()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
    }
    
    private func setupAuthErrorHandlerOnApiClient(){
        TPApiClient.authErrorDelegate = AuthErrorHandler()
    }

    private func setupSentry(instituteSettings: InstituteSettings) {
        SentrySDK.start { options in
            options.dsn = instituteSettings.sentryDSN
            options.debug = false
        }

        if let buildID = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String {
            SentrySDK.configureScope { scope in
                scope.setTag(value: buildID, key: "build.id")
            }
        }

        if KeychainTokenItem.isExist() {
            let user = Sentry.User()
            user.username = KeychainTokenItem.getAccount()
            SentrySDK.setUser(user)
        }
    }

    private func restrictScreenRecording(instituteSettings: InstituteSettings) {
        if !instituteSettings.AllowScreenShotInApp {
            NotificationCenter.default.addObserver(self, selector: #selector(screenRecordingChanged), name: UIScreen.capturedDidChangeNotification, object: nil)
        }
    }
}

extension AppDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        UserDefaults.standard.set(fcmToken, forKey: Constants.FCM_TOKEN)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Convert token to string
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        if ((UserDefaults.standard.string(forKey: Constants.DEVICE_TOKEN) != deviceTokenString)) {
            UserDefaults.standard.set(deviceTokenString, forKey: Constants.DEVICE_TOKEN)
            UserDefaults.standard.set("true", forKey: Constants.REGISTER_DEVICE_TOKEN)
            
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint("Unable to register for remote notifications: \(error.localizedDescription)")
        UserDefaults.standard.set("false", forKey: Constants.REGISTER_DEVICE_TOKEN)
    }
    
    
    // Receive displayed notifications for iOS 10 devices.
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge,.alert,.sound])
    }
    
    // [END ios_10_message_handling]
    
    
    //Called when a notification is interacted with for a background app.
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        if let url: String = userInfo["gcm.notification.short_url"] as? String  {
            let urlPath = URL(fileURLWithPath: url)
            let contentType = urlPath.pathComponents[1]
            if let topController = UIApplication.topViewController() {
                if (KeychainTokenItem.isExist()) {
                    switch(contentType) {
                    case "p":
                        let storyboard = UIStoryboard(name: Constants.POST_STORYBOARD, bundle: nil)
                        let viewController = storyboard.instantiateViewController(withIdentifier:
                            Constants.POST_DETAIL_VIEW_CONTROLLER) as! PostDetailViewController
                        
                        let url = TestpressCourse.shared.baseURL + "/api/v2.2/posts/\(urlPath.pathComponents[2])/?short_link=true"
                        viewController.url = url
                        
                        topController.present(viewController, animated: true, completion: nil)
                        break;
                    case "chapters":
                        emptyView = EmptyView.getInstance(parentView: topController.view)
                        emptyView.backgroundColor = .white
                        activityIndicator = UIUtils.initActivityIndicator(parentView: topController.view)
                        activityIndicator?.center = CGPoint(x: topController.view.center.x, y: topController.view.center.y - 50)
                        activityIndicator.startAnimating()
                        
                        let url = TestpressCourse.shared.baseURL + "/api/v2.2/contents/\(urlPath.pathComponents[3])/"
                        Content.fetchContent(url: url, completion: { content, error in
                            if let error = error {
                                debugPrint(error.message ?? "No error")
                                debugPrint(error.kind)
                                var retryButtonText: String?
                                var retryHandler: (() -> Void)?
                                if error.kind == .network {
                                    retryButtonText = Strings.TRY_AGAIN
                                    retryHandler = {
                                        self.emptyView.hide()
                                    }
                                }
                                self.activityIndicator.stopAnimating()
                                let (image, title, description) = error.getDisplayInfo()
                                
                                self.emptyView.show(image: image, title: title, description: description,
                                                    retryButtonText: retryButtonText, retryHandler: retryHandler)
                            } else {
                                self.activityIndicator.stopAnimating()
                                let storyboard = UIStoryboard(name: Constants.CHAPTER_CONTENT_STORYBOARD, bundle: TestpressCourse.bundle)
                                let viewController = storyboard.instantiateViewController(withIdentifier:
                                    Constants.CONTENT_DETAIL_PAGE_VIEW_CONTROLLER) as! ContentDetailPageViewController
                                
                                viewController.position = 0
                                viewController.contents = [content] as! [Content]
                                
                                topController.present(viewController, animated: true, completion: nil)
                            }
                        })
                        break;
                    default:
                        break;
                    }
                } else {
                    let storyboard = UIStoryboard(name: Constants.MAIN_STORYBOARD, bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier:
                        Constants.LOGIN_VIEW_CONTROLLER) as! LoginViewController
                    topController.present(viewController, animated: true, completion: nil)
                    
                }
            }
        }
        completionHandler()
    }
    
    @objc func screenRecordingChanged() {
        if UIScreen.main.isCaptured {
            addBlurView(withMessage: "Screen recording is not allowed.")
        } else {
            removeBlurView()
        }
    }

    func addBlurView(withMessage message: String) {
        guard blurEffectView == nil else { return }
        
        blurEffectView = createBlurEffectView()
        let warningLabel = createWarningLabel(withMessage: message)
        
        blurEffectView?.contentView.addSubview(warningLabel)
        centerLabelInBlurView(warningLabel)
        
        window?.addSubview(blurEffectView!)
    }

    private func createBlurEffectView() -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = window?.bounds ?? .zero
        return blurEffectView
    }

    private func createWarningLabel(withMessage message: String) -> UILabel {
        let warningLabel = UILabel()
        warningLabel.text = message
        warningLabel.textColor = .white
        warningLabel.font = UIFont.boldSystemFont(ofSize: 20)
        warningLabel.textAlignment = .center
        warningLabel.translatesAutoresizingMaskIntoConstraints = false
        return warningLabel
    }

    private func centerLabelInBlurView(_ label: UILabel) {
        guard let blurEffectView = blurEffectView else { return }
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: blurEffectView.contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: blurEffectView.contentView.centerYAnchor)
        ])
    }

    func removeBlurView() {
        blurEffectView?.removeFromSuperview()
        blurEffectView = nil
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
