/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    A struct for accessing generic password keychain items.
*/

import Foundation

struct KeychainTokenItem {
    // MARK: Types
    
    enum KeychainError: Error {
        case noPassword
        case unexpectedPasswordData
        case unexpectedItemData
        case unhandledError(status: OSStatus)
    }
    
    // MARK: Properties
    
    let service: String
    
    private(set) var account: String
    
    let accessGroup: String?

    // MARK: Intialization
    
    init(service: String, account: String, accessGroup: String? = nil) {
        self.service = service
        self.account = account
        self.accessGroup = accessGroup
    }
    
    // MARK: Keychain access
    
    func readPassword() throws -> String  {
        /*
            Build a query to find the item that matches the service, account and
            access group.
        */
        var query = KeychainTokenItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue
        
        // Try to fetch the existing keychain item that matches the query.
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        // Check the return status and throw an error if appropriate.
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        
        // Parse the password string from the query result.
        guard let existingItem = queryResult as? [String : AnyObject],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: String.Encoding.utf8)
        else {
            throw KeychainError.unexpectedPasswordData
        }
        
        return password
    }
    
    func savePassword(_ password: String) throws {
        // Encode the password into an Data object.
        let encodedPassword = password.data(using: String.Encoding.utf8)!
        
        do {
            // Check for an existing item in the keychain.
            try _ = readPassword()

            // Update the existing item with the new password.
            var attributesToUpdate = [String : AnyObject]()
            attributesToUpdate[kSecValueData as String] = encodedPassword as AnyObject?

            let query = KeychainTokenItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            
            // Throw an error if an unexpected status was returned.
            guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        }
        catch KeychainError.noPassword {
            /*
                No password was found in the keychain. Create a dictionary to save
                as a new keychain item.
            */
            var newItem = KeychainTokenItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
            newItem[kSecValueData as String] = encodedPassword as AnyObject?
            
            // Add a the new item to the keychain.
            let status = SecItemAdd(newItem as CFDictionary, nil)
            
            // Throw an error if an unexpected status was returned.
            guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        }
    }
    
    mutating func renameAccount(_ newAccountName: String) throws {
        // Try to update an existing item with the new account name.
        var attributesToUpdate = [String : AnyObject]()
        attributesToUpdate[kSecAttrAccount as String] = newAccountName as AnyObject?
        
        let query = KeychainTokenItem.keychainQuery(withService: service, account: self.account, accessGroup: accessGroup)
        let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
        
        // Throw an error if an unexpected status was returned.
        guard status == noErr || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
        
        self.account = newAccountName
    }
    
    func deleteItem() throws {
        // Delete the existing item from the keychain.
        let query = KeychainTokenItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
        let status = SecItemDelete(query as CFDictionary)
        
        // Throw an error if an unexpected status was returned.
        guard status == noErr || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
    }
    
    static func passwordItems(forService service: String, accessGroup: String? = nil) throws -> [KeychainTokenItem] {
        // Build a query for all items that match the service and access group.
        var query = KeychainTokenItem.keychainQuery(withService: service, accessGroup: accessGroup)
        query[kSecMatchLimit as String] = kSecMatchLimitAll
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanFalse
        
        // Fetch matching items from the keychain.
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        // If no items were found, return an empty array.
        guard status != errSecItemNotFound else { return [] }

        // Throw an error if an unexpected status was returned.
        guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        
        // Cast the query result to an array of dictionaries.
        guard let resultData = queryResult as? [[String : AnyObject]] else { throw KeychainError.unexpectedItemData }
        
        // Create a `KeychainPasswordItem` for each dictionary in the query result.
        var passwordItems = [KeychainTokenItem]()
        for result in resultData {
            guard let account  = result[kSecAttrAccount as String] as? String else {
                continue
            }
            
            let passwordItem = KeychainTokenItem(service: service, account: account, accessGroup: accessGroup)
            passwordItems.append(passwordItem)
        }
        
        return passwordItems
    }

    // MARK: Convenience
    
    private static func keychainQuery(withService service: String, account: String? = nil, accessGroup: String? = nil) -> [String : AnyObject] {
        var query = [String : AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = service as AnyObject?

        if let account = account {
            query[kSecAttrAccount as String] = account as AnyObject?
        }

        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }
        
        return query
    }
    
    static func passwordItems() -> [KeychainTokenItem] {
        var passwordItems = [KeychainTokenItem]()
        do {
            passwordItems =
                try KeychainTokenItem.passwordItems(forService: Constants.KEYCHAIN_SERVICE_NAME)
        } catch {
            fatalError("Error fetching password items - \(error)")
        }
        return passwordItems
    }
    
    static func isExist() -> Bool {
        return !passwordItems().isEmpty
    }
    
    static func getToken() -> String {
        do {
            return try passwordItems()[0].readPassword()
        } catch {
            fatalError("Error reading password from keychain - \(error)")
        }
    }
    
    static func clearKeychainItems() {
        for passwordItem in passwordItems() {
            do {
                try passwordItem.deleteItem()
            } catch {
                fatalError("Error deleting keychain item - \(error)")
            }
        }
    }
    
    
   static func addKeychainData(itemKey: String, itemValue: String) throws {
        guard let valueData = itemValue.data(using: .utf8) else {
            print("Keychain: Unable to store data, invalid input - key: \(itemKey), value: \(itemValue)")
            return
        }
        
        //delete old value if stored first
        do {
            try deleteKeychainData(itemKey: itemKey)
        } catch {
            print("Keychain: nothing to delete...")
        }
        
        let queryAdd: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: itemKey as AnyObject,
            kSecValueData as String: valueData as AnyObject,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        let resultCode: OSStatus = SecItemAdd(queryAdd as CFDictionary, nil)
        
        if resultCode != 0 {
            print("Keychain: value not added - Error: \(resultCode)")
        } else {
            print("Keychain: value added successfully")
        }
    }
    
   static func deleteKeychainData(itemKey: String) throws {
        let queryDelete: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: itemKey as AnyObject
        ]
        
        let resultCodeDelete = SecItemDelete(queryDelete as CFDictionary)
        
        if resultCodeDelete != 0 {
            print("Keychain: unable to delete from keychain: \(resultCodeDelete)")
        } else {
            print("Keychain: successfully deleted item")
        }
    }
    
   static func queryKeychainData (itemKey: String) throws -> String? {
        let queryLoad: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: itemKey as AnyObject,
            kSecReturnData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let resultCodeLoad = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(queryLoad as CFDictionary, UnsafeMutablePointer($0))
        }
        
        if resultCodeLoad != 0 {
            print("Keychain: unable to load data - \(resultCodeLoad)")
            return nil
        }
        
        guard let resultVal = result as? NSData, let keyValue = NSString(data: resultVal as Data, encoding: String.Encoding.utf8.rawValue) as String? else {
            print("Keychain: error parsing keychain result - \(resultCodeLoad)")
            return nil
        }
        return keyValue
    }
}
