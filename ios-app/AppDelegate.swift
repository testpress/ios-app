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
import RealmSwift
import UIKit
import Sentry


import Alamofire
import UserNotifications
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import AVKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    var window: UIWindow?
    
    var activityIndicator: UIActivityIndicatorView!
    var emptyView: EmptyView!
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        // Register for remote notifications. This shows a permission dialog on first run.
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        // [END register_for_notifications]
        FirebaseApp.configure()
        
        // [START set_messaging_delegate]
        Messaging.messaging().delegate = self
        // [END set_messaging_delegate]
        
        
        // Customise navigation bar
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().backgroundColor = Colors.getRGB(Colors.PRIMARY)
        UINavigationBar.appearance().barTintColor = Colors.getRGB(Colors.PRIMARY)
        UIBarButtonItem.appearance().tintColor = Colors.getRGB(Colors.PRIMARY_TEXT)
        UINavigationBar.appearance().titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: Colors.getRGB(Colors.PRIMARY_TEXT)]
        // Set tab bar item custom offset only on iPhone
        if !UIUtils.isiPad() {
            UITabBarItem.appearance().titlePositionAdjustment =
                UIOffset(horizontal: 0, vertical: -5)
        }
        do {
            if #available(iOS 10.0, *) {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            }
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        
        ApplicationDelegate.shared.application(application,
                                                  didFinishLaunchingWithOptions: launchOptions)
        
        IQKeyboardManager.sharedManager().enable = true
        
        // Clear keychain items if app is launching the first time after installation
        let userDefaults = UserDefaults.standard
        if userDefaults.bool(forKey: Constants.LAUNCHED_APP_BEFORE) == false {
            KeychainTokenItem.clearKeychainItems()
            
            userDefaults.set(true, forKey: Constants.LAUNCHED_APP_BEFORE)
            userDefaults.synchronize() // Forces the app to update UserDefaults
        }
        
        do {
            Client.shared = try Client(dsn: "https://b26e3d55ef144bdfbdd00ed9c63a09b7@sentry.testpress.in/4")
            try Client.shared?.startCrashHandler()
        } catch let error {
            print("\(error)")
        }
        
        if (KeychainTokenItem.isExist()) {
            Client.shared?.extra = [
                "username": KeychainTokenItem.getAccount()
            ]
        }
        
        let config = Realm.Configuration(schemaVersion: 23)
        Realm.Configuration.defaultConfiguration = config
        let viewController:UIViewController
        
        if (!InstituteSettings.isAvailable()) {
            viewController = MainViewController()
        } else {
            UIUtils.fetchInstituteSettings(completion:{ _,_  in })
            viewController = UIUtils.getLoginOrTabViewController()
        }
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
//        Zoom.enableFullScreenForMeetingWaitView()
        return true
    }
    
    
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
                        
                        let url = Constants.BASE_URL + "/api/v2.2/posts/\(urlPath.pathComponents[2])/?short_link=true"
                        viewController.url = url
                        
                        topController.present(viewController, animated: true, completion: nil)
                        break;
                    case "chapters":
                        emptyView = EmptyView.getInstance(parentView: topController.view)
                        emptyView.backgroundColor = .white
                        activityIndicator = UIUtils.initActivityIndicator(parentView: topController.view)
                        activityIndicator?.center = CGPoint(x: topController.view.center.x, y: topController.view.center.y - 50)
                        activityIndicator.startAnimating()
                        
                        let url = Constants.BASE_URL + "/api/v2.2/contents/\(urlPath.pathComponents[3])/"
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
                                let storyboard = UIStoryboard(name: Constants.CHAPTER_CONTENT_STORYBOARD, bundle: nil)
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
