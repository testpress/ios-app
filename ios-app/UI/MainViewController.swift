//
//  MainViewController.swift
//  ios-app
//
//  Created by Karthik on 07/12/18.
//  Copyright © 2018 Testpress. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    
    var activityIndicator: UIActivityIndicatorView!
    var emptyView: EmptyView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        emptyView = EmptyView.getInstance(parentView: view)
        activityIndicator = UIUtils.initActivityIndicator(parentView: view)
        let screenSize: CGRect = UIScreen.main.bounds
        activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y - getNavBarHeight())
        let navBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: screenSize.width, height: getNavBarHeight()))
        let navItem = UINavigationItem(title: Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String);
        navBar.setItems([navItem], animated: false);

        self.view.addSubview(navBar);
        self.fetchInstitueSettings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !InstituteSettings.isAvailable() {
            self.fetchInstitueSettings()
        } else {
            UIUtils.fetchInstituteSettings(completion:{ _,_  in })
            self.showView()
            self.checkPermissions()
        }
    }
    
    func showView() {
        self.activityIndicator.stopAnimating()
        let viewController = UIUtils.getLoginOrTabViewController()
        present(viewController, animated: false, completion: nil)
    }
    
    func checkPermissions() {
        let instituteSettings = DBManager<InstituteSettings>().getResultsFromDB()[0]
        if instituteSettings.forceStudentData {
            TPApiClient.apiCall(endpointProvider: TPEndpointProvider(.checkPermission),completion: {
                json, error in
                var checkPermission: CheckPermission? = nil
                if let json = json {
                    checkPermission = TPModelMapper<CheckPermission>().mapFromJSON(json: json)
                    if (checkPermission != nil) {
                        if !((checkPermission?.is_data_collected)!) {
                            let viewController = WebViewController()
                            viewController.url = "&next=/settings/force/mobile"
                            viewController.use_sso_login = true
                            UIApplication.topViewController()?.present(viewController, animated: true, completion: nil)
                        }
                    }
                }
            })
        }
    }
    
    func fetchInstitueSettings() {
        activityIndicator.startAnimating()

        UIUtils.fetchInstituteSettings(
            completion: { instituteSettings, error in
                if let error = error {
                    debugPrint(error.message ?? "No error")
                    debugPrint(error.kind)
                    var retryButtonText: String?
                    var retryHandler: (() -> Void)?
                    if error.kind == .network {
                        retryButtonText = Strings.TRY_AGAIN
                        retryHandler = {
                            self.emptyView.hide()
                            self.fetchInstitueSettings()
                        }
                    }
                    self.activityIndicator.stopAnimating()
                    let (image, title, description) = error.getDisplayInfo()
                    
                    self.emptyView.show(image: image, title: title, description: description,
                                        retryButtonText: retryButtonText, retryHandler: retryHandler)
                } else {
                    self.activityIndicator.stopAnimating()
                    self.showView()
                }
                
        })
    }
    
    
    func getNavBarHeight() -> CGFloat {
        return UINavigationController().navigationBar.frame.size.height
    }
}
