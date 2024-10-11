//
//  LearnTabController.swift
//  ios-app
//
//  Created by Testpress on 10/10/24.
//  Copyright © 2024 Testpress. All rights reserved.
//

import Foundation
import UIKit
import CourseKit


public class LearnTabController: UINavigationController {
    public init() {
        super.init(nibName: nil, bundle: nil)
        self.setupLearnTab()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupLearnTab()
    }
    
    private func setupLearnTab() {
        let viewController = TestpressCourse.shared.getMyCoursesViewController()
        self.pushViewController(viewController!, animated: false)
    }
}
