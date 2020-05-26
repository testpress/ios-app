//
//  AttemptRepository.swift
//  ios-app
//
//  Created by Karthik on 12/05/20.
//  Copyright © 2020 Testpress. All rights reserved.
//

import Foundation

class AttemptRepository {
    func loadAttempt(attemptsUrl: String, completion: @escaping(ContentAttempt?, TPError?) -> Void) {
        TPApiClient.request(type: ContentAttempt.self, endpointProvider: TPEndpointProvider(.post, url: attemptsUrl), completion: completion)
    }
}
