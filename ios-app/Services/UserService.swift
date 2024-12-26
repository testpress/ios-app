//
//  UserService.swift
//  ios-app
//
//  Created by Testpress on 26/12/24.
//  Copyright © 2024 Testpress. All rights reserved.
//

import Foundation
import CourseKit

class UserService {
    static let shared = UserService()
    
    private init() {}
    
    func checkEnforceDataCollectionStatus(completion: @escaping (Bool?, TPError?) -> Void) {
        let endpointProvider = TPEndpointProvider(.checkEnforceDataCollectionStatus)
        
        TPApiClient.apiCall(
            endpointProvider: endpointProvider,
            completion: { response, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                guard let jsonString = response,
                      let jsonData = jsonString.data(using: .utf8),
                      let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Bool] else {
                    completion(nil, TPError(message: "Invalid response format", kind: .unexpected))
                    return
                }
                
                let isDataCollected = json!["is_data_collected"] ?? false
                completion(isDataCollected, nil)
            }
        )
    }
}
