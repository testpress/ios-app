//
//  EncryptionKeyRepository.swift
//  ios-app
//
//  Created by Karthik on 05/06/20.
//  Copyright © 2020 Testpress. All rights reserved.
//

import Foundation


class EncryptionKeyRepository {
    func load(url: URL, onSuccess: @escaping(Data) -> Void) {
        let encryptionKeyUrl = URLUtils.convertURLSchemeToHttps(url: url)
        let baseURLComponents = URLComponents(string: Constants.BASE_URL)!
        let baseHost = baseURLComponents.host!
        // Update the custom domain to the Testpress domain
        let finalURL = URLUtils.changeDomain(url: encryptionKeyUrl, newDomain: baseHost)
        fetchFromNetwork(url: finalURL) { key in
            onSuccess(key)
        }
    }
    
    private func fetchFromNetwork(url: URL, onSuccess: @escaping(Data) -> Void) {
        var request = URLRequest(url: url)
        request.setValue("JWT " + KeychainTokenItem.getToken(), forHTTPHeaderField: "Authorization")
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request) { data, response, _ in
            guard let key = data else { return }
            onSuccess(key)
        }
        task.resume()
    }
}
