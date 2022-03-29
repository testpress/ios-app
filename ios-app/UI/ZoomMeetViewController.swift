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
        emptyView = EmptyView.getInstance(parentView: containerView)
        initialize()
    }
    
    func initialize() {
        initializeLoadingScreen()
        initializeZoomSDK()
    }
    
    func initializeLoadingScreen() {
        let navbarAndStatusBarOffset: CGFloat = 70
        activityIndicator = UIUtils.initActivityIndicator(parentView: self.view)
        activityIndicator?.center = CGPoint(x: view.center.x, y: view.center.y + navbarAndStatusBarOffset)
    }
    
    func initializeZoomSDK() {
        let zoomSDK = MobileRTCSDKInitContext()
        zoomSDK.domain = "zoom.us"
        MobileRTC.shared().initialize(zoomSDK)
        let authService = MobileRTC.shared().getAuthService()
        authService?.delegate = self
        authService?.jwtToken = accessToken!
        authService?.sdkAuth()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showLoading()
        if isBackButtonPressedFromZoomMeeting() {
            /*
             If user presses back button from zoom meeting we should show content detail page.
             This is because this page is just to handle zoom meeting initialization,
             so appropriate screen to display is content detail page.
             */
            self.gotoPreviousPage()
        }
    }
    
    func showLoading() {
        activityIndicator?.startAnimating()
    }
    
    func stopLoading() {
        activityIndicator?.stopAnimating()
    }
    
    func isBackButtonPressedFromZoomMeeting() -> Bool {
        if let klass = NSClassFromString("ZMNavigationController") {
            if self.presentedViewController?.isKind(of: klass) ?? false{
                return true
            }
        }
        
        return false
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
        if (returnValue == MobileRTCAuthError.success) {
            prepareAndJoin()
        } else {
            refetchAccessTokenAndInitialize()
        }
    }
    
    func refetchAccessTokenAndInitialize() {
        fetchAccessToken() { accessToken, error in
            if (error != nil) {
                let (image, title, description) = error!.getDisplayInfo()
                self.emptyView.show(image: image, title: title, description: description)
                return
            }
            self.accessToken = accessToken!
            self.initializeZoomSDK()
        }
    }
    
    func prepareAndJoin() {
        showLoading()
        configureMeeting()
        // Zoom SDK requires view controller which joins zoom meet to be root view controller
        changeRootViewController()
        join()
    }
    
    func configureMeeting() {
        let meetingSettings = MobileRTC.shared().getMeetingSettings()
        meetingSettings?.meetingPasswordHidden = true
        meetingSettings?.meetingInviteHidden = true
        meetingSettings?.meetingShareHidden = true
    }
    
    func changeRootViewController() {
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        appDelegate.window?.rootViewController = self
    }
    
    func join() {
        if let service = MobileRTC.shared().getMeetingService() {
            service.delegate = self
            service.customizeMeetingTitle(meetingTitle)
            let joinParams = MobileRTCMeetingJoinParam()
            joinParams.userName = KeychainTokenItem.getAccount()
            joinParams.meetingNumber = meetingNumber
            joinParams.password = password
            service.joinMeeting(with: joinParams)
        }
    }
    
    func onMeetingStateChange(_ state: MobileRTCMeetingState) {
        if isNoMeetingRunning(meetingState: state) {
            gotoPreviousPage()
        }
    }
    
    func isNoMeetingRunning(meetingState: MobileRTCMeetingState) -> Bool {
        return meetingState == MobileRTCMeetingState.idle && !self.hasError
    }
    
    func onMeetingError(_ error: MobileRTCMeetError, message: String?) {
        stopLoading()
        if error == MobileRTCMeetError.success {
            return
        }
        
        self.hasError = true
        if isNetworkError(error: error){
            showErrorScreen(errorMessage: message ?? "")
        } else {
            showErrorScreen(errorMessage: message ?? "", allowRetry: false)
        }
    }
    
    func isNetworkError(error: MobileRTCMeetError) -> Bool {
        return error == MobileRTCMeetError.networkError || error == MobileRTCMeetError.reconnectError
    }
    
    func showErrorScreen(errorMessage: String, allowRetry: Bool = true) {
        let retryButtonText = allowRetry ? "Retry" : "Go Back"
        let retryHandler = allowRetry ? {self.prepareAndJoin()} : {self.gotoPreviousPage()}
        emptyView.show(image: Images.TestpressAlertWarning.image, title: "Error Occurred", description: errorMessage.capitalized, retryButtonText: retryButtonText,retryHandler: retryHandler)
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
    static func enableFullScreenForMeetingWaitView() {
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
