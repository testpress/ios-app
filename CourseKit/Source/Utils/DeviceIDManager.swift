//
//  DeviceIDManager.swift
//  CourseKit
//
//  Created by Balamurugan on 23/01/26.
//  Copyright © 2026 Testpress. All rights reserved.
//

import Foundation

public class DeviceIDManager {
    
    private static let deviceIDAccount = "device_uid"
    private static let deviceIDService = Constants.KEYCHAIN_SERVICE_NAME + ".device_id"
    
    public static func getDeviceID() -> String {
        let keychainItem = KeychainTokenItem(
            service: deviceIDService,
            account: deviceIDAccount
        )
        
        do {
            return try keychainItem.readPassword()
        } catch {
            let newID = UUID().uuidString
            try? keychainItem.savePassword(newID)
            return newID
        }
    }
}
