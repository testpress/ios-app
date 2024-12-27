//
//  MainViewController.swift
//  ios-app
//
//  Created by Karthik on 07/12/18.
//  Copyright © 2018 Testpress. All rights reserved.
//

import UIKit
import CourseKit
import Alamofire

class MainViewController: UIViewController {

    
    private var activityIndicator: UIActivityIndicatorView!
    private var emptyView: EmptyView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchInstituteSettings()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        setupEmptyView()
        setupActivityIndicator()
        setupNavigationBar()
    }
    
    private func setupEmptyView() {
        emptyView = EmptyView.getInstance(parentView: view)
    }
    
    private func setupActivityIndicator() {
        activityIndicator = UIUtils.initActivityIndicator(parentView: view)
        activityIndicator.center = CGPoint(
            x: view.center.x,
            y: view.center.y - navigationBarHeight
        )
    }
    
    private func setupNavigationBar() {
        let screenSize = UIScreen.main.bounds
        let navigationBar = UINavigationBar(frame: CGRect(
            x: 0,
            y: UIApplication.shared.statusBarFrame.height,
            width: screenSize.width,
            height: navigationBarHeight
        ))
        
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String
        let navigationItem = UINavigationItem(title: appName)
        navigationBar.setItems([navigationItem], animated: false)
        
        view.addSubview(navigationBar)
    }
    
    private func fetchInstituteSettings() {
        activityIndicator.startAnimating()
        
        if InstituteRepository.shared.isSettingsCached() {
            InstituteRepository.shared.getSettings(refresh: true) { [weak self] _, _ in }
            navigateToNextScreen()
            return
        }
        
        InstituteRepository.shared.getSettings { [weak self] instituteSettings, error in
            guard let self = self else { return }
            
            self.activityIndicator.stopAnimating()
            
            if let error = error {
                self.handleError(error)
            } else {
                self.navigateToNextScreen()
            }
        }
    }
    
    private func handleError(_ error: Error) {
        let tpError = error as! TPError
        debugPrint(tpError.message ?? "No error")
        debugPrint(tpError.kind)
        
        var retryButtonText: String?
        var retryHandler: (() -> Void)?
        
        if tpError.kind == .network {
            retryButtonText = Strings.TRY_AGAIN
            retryHandler = { [weak self] in
                self?.emptyView.hide()
                self?.fetchInstituteSettings()
            }
        }
        
        let (image, title, description) = tpError.getDisplayInfo()
        emptyView.show(
            image: image,
            title: title,
            description: description,
            retryButtonText: retryButtonText,
            retryHandler: retryHandler
        )
    }
    
    private func navigateToNextScreen() {
        guard isUserLoggedIn() && isNetworkReachable() else {
            showLoginOrHome()
            return
        }
        
        navigateBasedOnDataCollectionStatus()
    }
    
    private func navigateBasedOnDataCollectionStatus() {
        activityIndicator.startAnimating()
        
        UserService.shared.checkEnforceDataCollectionStatus { [weak self] isDataCollected, error in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            
            if let error = error {
                showLoginOrHome()
                return
            }
            
            if isDataCollected == true {
                showLoginOrHome()
            } else {
                showUserDataForm()
            }
        }
    }
    
    private func showUserDataForm() {
        let webViewController = UserDataFormViewController()
        webViewController.modalPresentationStyle = .fullScreen
        present(webViewController, animated: true)
    }
    
    private func showLoginOrHome() {
        let viewController = UserHelper.getLoginOrTabViewController()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let window = appDelegate.window else {
            return
        }
        
        window.rootViewController = viewController
    }
    
    private var navigationBarHeight: CGFloat {
        UINavigationController().navigationBar.frame.size.height
    }
}
