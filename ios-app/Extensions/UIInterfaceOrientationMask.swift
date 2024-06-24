//
//  UIInterfaceOrientationMask.swift
//  ios-app
//
//  Created by Testpress on 17/06/23.
//  Copyright © 2023 Testpress. All rights reserved.
//

import Foundation
import UIKit


extension UIInterfaceOrientationMask {
    var toUIInterfaceOrientation: UIInterfaceOrientation {
        switch self {
        case .portrait:
            return UIInterfaceOrientation.portrait
        case .landscapeRight:
            return UIInterfaceOrientation.landscapeRight
        default:
            return UIInterfaceOrientation.unknown
        }
    }
}
