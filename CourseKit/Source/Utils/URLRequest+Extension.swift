//
//  URLRequest+Extension.swift
//  CourseKit
//
//  Created by Balamurugan on 23/01/26.
//  Copyright © 2026 Testpress. All rights reserved.
//

import Foundation

extension URLRequest {
    init(url: URL, includeDeviceUID: Bool = true) {
        self.init(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60.0)
        
        if includeDeviceUID {
            self.addDeviceHeaders()
        }
    }
    
    mutating func addDeviceHeaders() {
        self.setValue(DeviceIDManager.getDeviceID(), forHTTPHeaderField: "X-Device-UID")
        self.setValue("mobile_app", forHTTPHeaderField: "X-Device-Type")
    }
}
