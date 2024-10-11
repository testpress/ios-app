//
//  LearnTabController.swift
//  ios-app
//
//  Created by Testpress on 11/10/24.
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
        let storyboard = UIStoryboard(name: Constants.MAIN_STORYBOARD, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "CoursesTableViewController") as? CoursesTableViewController
        viewController?.title = "Learn"
        viewController?.tabBarItem.image = Images.LearnNavBarIcon.image
        
        self.pushViewController(viewController!, animated: false)
    }
}
