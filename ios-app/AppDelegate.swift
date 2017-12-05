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

import IQKeyboardManagerSwift
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Customise navigation bar
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().backgroundColor = Colors.getRGB(Colors.PRIMARY)
        UINavigationBar.appearance().barTintColor = Colors.getRGB(Colors.PRIMARY)
        UIBarButtonItem.appearance().tintColor = Colors.getRGB(Colors.PRIMARY_TEXT)
        UINavigationBar.appearance().titleTextAttributes =
            [NSAttributedStringKey.foregroundColor: Colors.getRGB(Colors.PRIMARY_TEXT)]
        
        UIApplication.shared.isStatusBarHidden = false
        let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar")
            as? UIView

        statusBar?.backgroundColor = Colors.getRGB(Colors.PRIMARY)
        
        // Set tab bar item custom offset only on iPhone
        if !UIUtils.isiPad() {
            UITabBarItem.appearance().titlePositionAdjustment =
                UIOffset(horizontal: 0, vertical: -5)
        }
        
        IQKeyboardManager.sharedManager().enable = true
        
        // Clear keychain items if app is launching the first time after installation
        let userDefaults = UserDefaults.standard
        if userDefaults.bool(forKey: Constants.LAUNCHED_APP_BEFORE) == false {
            KeychainTokenItem.clearKeychainItems()
            
            userDefaults.set(true, forKey: Constants.LAUNCHED_APP_BEFORE)
            userDefaults.synchronize() // Forces the app to update UserDefaults
        }
        
        // Launch the view controller based on user login state
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var viewController: UIViewController
        if (KeychainTokenItem.isExist()) {
            viewController = storyboard.instantiateViewController(withIdentifier:
                Constants.TAB_VIEW_CONTROLLER)
        } else {
            viewController = storyboard.instantiateViewController(withIdentifier:
                Constants.LOGIN_VIEW_CONTROLLER) as! LoginViewController
        }
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        return true
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

