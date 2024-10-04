//
//  DashboardRepository.swift
//  ios-app
//
//  Created by Karthik on 29/04/21.
//  Copyright © 2021 Testpress. All rights reserved.
//

import Foundation
import CourseKit

class DashboardRepository {
    let DASHBOARD_STORAGE_KEY = "dashboardData"

    func get(completion: @escaping(DashboardResponse?, TPError?) -> Void) {
        do {
            let data = try UserDefaults.standard.getObject(forKey: DASHBOARD_STORAGE_KEY, castTo: DashboardResponse.self)
            completion(data, nil)
        } catch {
            fetch { response, error in
              completion(response, error)
            }
        }
    }
    
    func fetch(completion: @escaping(DashboardResponse?, TPError?) -> Void) {
        TPApiClient.request(type: DashboardResponse.self, endpointProvider: TPEndpointProvider(.dashboard), completion: {response, error in
            if response != nil {
                do {
                    try UserDefaults.standard.saveObject(response!, forKey: self.DASHBOARD_STORAGE_KEY)
                    completion(response, error)
                } catch {
                }
            }
        })
    }
    
    func refresh(completion: @escaping(DashboardResponse?, TPError?) -> Void) {
        fetch { response, error in
          completion(response, error)
        }
    }
}
