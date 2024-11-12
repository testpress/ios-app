//
//  OfflineDownloadsTabController.swift
//  ios-app
//
//  Created by Prithuvi on 08/11/24.
//  Copyright © 2024 Testpress. All rights reserved.
//

import Foundation
import UIKit
import CourseKit

public class OfflineDownloadsTabController: UINavigationController {
    public init() {
        super.init(nibName: nil, bundle: nil)
        self.setupOfflineDownloadsTab()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupOfflineDownloadsTab()
    }

    private func setupOfflineDownloadsTab() {
        let viewController = TestpressCourse.shared.getOfflineDownloadsViewController()
        viewController?.title = "Offline Downloads"
        viewController?.tabBarItem.image = Images.LearnNavBarIcon.image
        
        self.pushViewController(viewController!, animated: false)
    }
}
