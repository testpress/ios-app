//
//  ZoomMeetViewController.swift
//  ios-app
//
//  Copyright © 2020 Testpress. All rights reserved.
//

import UIKit
import MobileRTC
import MobileCoreServices


class ZoomMeetViewController: UIViewController, MobileRTCAuthDelegate, MobileRTCMeetingServiceDelegate, UIAdaptivePresentationControllerDelegate {
    
    var activityIndicator: UIActivityIndicatorView!
    var accessToken: String!
    var meetingNumber: String!
    var password: String!
    var meetingTitle: String!
    var hasError: Bool = false
    var emptyView: EmptyView!
    var fetchAccessToken: ((_ completion: @escaping(String?, TPError?) -> Void) -> Void)!
    @IBOutlet weak var containerView: UIStackView!
    
    override func viewDidLoad() {
        self.setStatusBarColor()
        initializeLoadingScreen()
        emptyView = EmptyView.getInstance(parentView: containerView)
        self.initialize()
    }
    
    func initializeLoadingScreen() {
        activityIndicator = UIUtils.initActivityIndicator(parentView: self.view)
        activityIndicator?.center = CGPoint(x: view.center.x, y: view.center.y + 70)
        let pagingSpinner = UIActivityIndicatorView(style: .gray)
        pagingSpinner.startAnimating()
        pagingSpinner.color = Colors.getRGB(Colors.PRIMARY)
        pagingSpinner.hidesWhenStopped = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        activityIndicator?.startAnimating()
        openPreviousPageIfBackButtonPressedFromZoom()
    }
    
    func openPreviousPageIfBackButtonPressedFromZoom() {
        if let klass = NSClassFromString("ZMNavigationController") {
            if self.presentedViewController?.isKind(of: klass) ?? false{
                self.gotoPreviousPage()
            }
        }
    }
    
    func initialize() {
        let zoomSDK = MobileRTCSDKInitContext()
        zoomSDK.domain = "zoom.us"
        zoomSDK.enableLog = true
        MobileRTC.shared().initialize(zoomSDK)
        let authService = MobileRTC.shared().getAuthService()
        authService?.delegate = self
        authService?.jwtToken = accessToken!
        authService?.sdkAuth()
    }
    
    @IBAction func back(_ sender: Any) {
        gotoPreviousPage()
    }
    
    func gotoPreviousPage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier:
            Constants.TAB_VIEW_CONTROLLER)
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        appDelegate.window?.rootViewController = viewController
    }
    
    func onMobileRTCAuthReturn(_ returnValue: MobileRTCAuthError) {
        if (returnValue != MobileRTCAuthError_Success) {
            fetchAccessToken() { accessToken, error in
                if (error != nil) {
                    let (image, title, description) = error!.getDisplayInfo()
                    self.emptyView.show(image: image, title: title, description: description)
                    return
                }
                self.accessToken = accessToken!
                self.initialize()
            }
            return
        }
        self.join()
    }
    
    func join() {
        activityIndicator?.startAnimating()
        let getservice = MobileRTC.shared().getMeetingService()
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        appDelegate.window?.rootViewController = self
        configureMeeting()
        
        if let service = getservice {
            service.delegate = self
            service.customizeMeetingTitle(meetingTitle)
            let joinParams = MobileRTCMeetingJoinParam()
            joinParams.userName = KeychainTokenItem.getAccount()
            joinParams.meetingNumber = meetingNumber
            joinParams.password = password
            service.joinMeeting(with: joinParams)
        }
    }
    
    func configureMeeting() {
        let meetingSettings = MobileRTC.shared().getMeetingSettings()
        meetingSettings?.meetingPasswordHidden = true
        meetingSettings?.meetingInviteHidden = true
        meetingSettings?.meetingShareHidden = true
    }
    
    func onMeetingStateChange(_ state: MobileRTCMeetingState) {
        if (state == MobileRTCMeetingState_Idle && !self.hasError) {
            activityIndicator?.stopAnimating()
            gotoPreviousPage()
        }
    }
    
    func onMeetingError(_ error: MobileRTCMeetError, message: String?) {
        activityIndicator?.stopAnimating()
        if error != MobileRTCMeetError_Success {
            self.hasError = true
            if error == MobileRTCMeetError_NetworkError || error == MobileRTCMeetError_ReconnectError {
                emptyView.show(image: Images.TestpressAlertWarning.image, title: "Error Occurred", description: message?.capitalized, retryButtonText: "Go Back",
                               retryHandler: { self.join()})
            } else {
                emptyView.show(image: Images.TestpressAlertWarning.image, title: "Error Occurred", description: message?.capitalized, retryButtonText: "Go Back",
                               retryHandler: { self.gotoPreviousPage()})
            }
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        deInitializeZoomSdk()
    }
    
    func deInitializeZoomSdk() {
        let authService = MobileRTC.shared().getAuthService()
        authService?.delegate = nil
        let meetingService = MobileRTC.shared().getMeetingService()
        meetingService?.delegate = nil
    }
}

class Zoom {
    static func showWaitViewControllerInFullScreen() {
        if let klass = NSClassFromString("ZPMeetingWaitViewController") {
            guard let original = class_getInstanceMethod(klass, #selector(getter: UIViewController.modalPresentationStyle)), let replacement = class_getInstanceMethod(self, #selector(getter:Zoom.modalPresentationStyle))
                else { return }
            method_exchangeImplementations(original, replacement)
        } else {
            debugPrint("No Class named `ZPMeetingWaitViewController`")
        }
    }
    
    @objc var modalPresentationStyle: UIModalPresentationStyle {
        .fullScreen
    }
}
