//
//  Reachablity.swift
//  ios-app
//
//  Created by Testpress on 27/12/24.
//  Copyright © 2024 Testpress. All rights reserved.
//

import Foundation
import Alamofire

func isNetworkReachable() -> Bool {
    return Alamofire.NetworkReachabilityManager()?.isReachable ?? false
}
