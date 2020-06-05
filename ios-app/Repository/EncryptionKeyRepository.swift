//
//  EncryptionKeyRepository.swift
//  ios-app
//
//  Created by Karthik on 05/06/20.
//  Copyright © 2020 Testpress. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper


class EncryptionKeyRepository {
    func load(url: URL, onSuccess: @escaping(Data) -> Void) {
        let encryptionKeyUrl = URLUtils.convertURLSchemeToHttps(url: url)
        let key: Data? = getKey(url: encryptionKeyUrl.absoluteString)
        
        if (key != nil) {
            onSuccess(key!)
        } else {
            fetch(url: encryptionKeyUrl) { _ in
                onSuccess(self.getKey(url: encryptionKeyUrl.absoluteString)!)
            }
        }
    }
    
    private func getKey(url: String) -> Data? {
        return KeychainWrapper.standard.data(forKey: url)
    }
    
    private func storeKey(url: String, key: Data) {
        KeychainWrapper.standard.set(key, forKey: url)
    }
    
    private func fetch(url: URL, onSuccess: @escaping(Data) -> Void) {
        var request = URLRequest(url: url)
        request.setValue("JWT " + KeychainTokenItem.getToken(), forHTTPHeaderField: "Authorization")
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request) { data, response, _ in
            guard let key = data else { return }
            self.storeKey(url: url.absoluteString, key: key)
            onSuccess(key)
        }
        task.resume()
    }
}
