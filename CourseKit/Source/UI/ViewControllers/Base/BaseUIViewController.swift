//
//  BaseUIViewController.swift
//  CourseKit
//
//  Created by Testpress on 25/10/24.
//  Copyright © 2024 Testpress. All rights reserved.
//

import Foundation
import UIKit

open class BaseUIViewController: UIViewController {
    open override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
        }
    }
}
