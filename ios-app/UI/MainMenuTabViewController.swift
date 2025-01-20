//
//  MainMenuTabViewController.swift
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
import Alamofire
import CourseKit
import SFMCSDK
import MarketingCloudSDK
import Sentry

class MainMenuTabViewController: UITabBarController {
    
    var instituteSettings: InstituteSettings!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStatusBarColor()
        instituteSettings = DBManager<InstituteSettings>().getResultsFromDB()[0]
        viewControllers?[5].tabBarItem.title = instituteSettings.postsLabel
        
        if(!instituteSettings.isVideoDownloadEnabled){
            viewControllers?.remove(at: 8) // Offline Download List
        }
        
        viewControllers?.remove(at: 7) // Access code
        
        if (!instituteSettings.postsEnabled) {
            viewControllers?.remove(at: 5)
        }
        
        if (!instituteSettings.coursesEnableGamification) {
            viewControllers?.remove(at: 4)
        }
        
        if (instituteSettings.showGameFrontend) {
            viewControllers?.remove(at: 3) // Exams list
            
        } else {
            viewControllers?.remove(at: 2)
        }
        
        if (!instituteSettings.activityFeedEnabled) {
            viewControllers?.remove(at: 1)
        }
        
        addDoubtsWebViewController()
        addDiscussionsWebViewController()
        
        if (UserDefaults.standard.string(forKey: Constants.REGISTER_DEVICE_TOKEN) == "true") {
            let deviceToken = UserDefaults.standard.string(forKey: Constants.DEVICE_TOKEN)
            let fcmToken = UserDefaults.standard.string(forKey: Constants.FCM_TOKEN)
            let parameters: Parameters = [
                "device_id": deviceToken!,
                "registration_id": fcmToken!,
                "platform": "ios"
            ]
            TPApiClient.apiCall(endpointProvider: TPEndpointProvider(.registerDevice), parameters: parameters,completion: { _, _ in})
        }
        
        if instituteSettings.salesforceSdkEnabled {
            self.configureSalesforceSDK()
        }
    }
    
    func configureSalesforceSDK() {
        let mobilePushConfiguration = PushConfigBuilder(appId: instituteSettings.salesforceMcApplicationId ?? "")
            .setAccessToken(instituteSettings.salesforceMcAccessToken ?? "")
            .setMarketingCloudServerUrl(URL(string: instituteSettings.salesforceMarketingCloudUrl ?? "")!)
            .setMid(instituteSettings.salesforceMid ?? "")
            .setInboxEnabled(false)
            .setLocationEnabled(false)
            .setAnalyticsEnabled(true)
            .build()
        
        let completionHandler: (OperationResult) -> () = { result in
            if result == .error {
                SentrySDK.capture(message: "Salesforce SDK integration error.")
            } else if result == .cancelled {
                SentrySDK.capture(message: "Salesforce SDK integration cancelled.")
            } else if result == .timeout {
                SentrySDK.capture(message: "Salesforce SDK integration timeout.")
            }
        }
        
        SFMCSdk.initializeSdk(ConfigBuilder().setPush(config: mobilePushConfiguration, onCompletion: completionHandler).build())
    }
    
    private func addDoubtsWebViewController() {
        guard instituteSettings.isHelpdeskEnabled else { return }

        let doubtsWebViewController = self.getDoubtsWebViewController()
        if (viewControllers?.count ?? 0) > 3 {
            viewControllers?.insert(doubtsWebViewController, at: 2)
        } else {
            viewControllers?.append(doubtsWebViewController)
        }
    }
    
    func getDoubtsWebViewController() -> WebViewController {
        let secondViewController = WebViewController()
        secondViewController.url = "&next=/tickets/mobile"
        secondViewController.useWebviewNavigation = true
        secondViewController.useSSOLogin = true
        secondViewController.shouldOpenLinksWithinWebview = true
        secondViewController.title = "Doubts"
        secondViewController.displayNavbar = true
        secondViewController.tabBarItem.image = Images.DoubtsIcon.image
        return secondViewController
    }
    
    private func addDiscussionsWebViewController() {
        guard instituteSettings.forumEnabled else { return }

        let discussionsWebViewController = self.getDoubtsWebViewController()
        if (viewControllers?.count ?? 0) > 4 {
            viewControllers?.insert(getDiscussionsWebViewController(), at: 3)
        } else {
            viewControllers?.append(discussionsWebViewController)
        }
    }
    
    func getDiscussionsWebViewController() -> WebViewController {
        let secondViewController = WebViewController()
        secondViewController.url = "&next=/discussions/new"
        secondViewController.useWebviewNavigation = true
        secondViewController.useSSOLogin = true
        secondViewController.shouldOpenLinksWithinWebview = true
        secondViewController.title = "Discussions"
        secondViewController.displayNavbar = true
        secondViewController.tabBarItem.image = Images.DiscussionsIcon.image
        return secondViewController
    }
}
