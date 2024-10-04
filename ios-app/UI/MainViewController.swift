//
//  MainViewController.swift
//  ios-app
//
//  Created by Karthik on 07/12/18.
//  Copyright © 2018 Testpress. All rights reserved.
//

import UIKit
import CourseKit

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
                    let viewController = UIUtils.getLoginOrTabViewController()
                    self.present(viewController, animated: false, completion: nil)
                }
                
        })
    }
    
    
    func getNavBarHeight() -> CGFloat {
        return UINavigationController().navigationBar.frame.size.height
    }
}
