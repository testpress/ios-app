//
//  InstituteRepository.swift
//  CourseKit
//
//  Created by Testpress on 08/10/24.
//  Copyright © 2024 Testpress. All rights reserved.
//

import Foundation

public class InstituteRepository {

    public static let shared = InstituteRepository()

    private init() {}
    
    public func isSettingsCached() -> Bool {
        return fetchFromDB() != nil
    }

    public func getSettings(refresh: Bool = false, completion: @escaping (InstituteSettings?, TPError?) -> Void) {
        if refresh {
            fetchFromAPI(completion: completion)
        } else {
            if let cachedSettings = fetchFromDB() {
                completion(cachedSettings, nil)
            } else {
                fetchFromAPI(completion: completion)
            }
        }
    }

    private func fetchFromDB() -> InstituteSettings? {
        return DBManager<InstituteSettings>().getResultsFromDB().first
    }

    private func fetchFromAPI(completion: @escaping (InstituteSettings?, TPError?) -> Void) {
        TPApiClient.request(
            type: InstituteSettings.self,
            endpointProvider: TPEndpointProvider(.instituteSettings),
            completion: { instituteSettings, error in
                if let settings = instituteSettings {
                    settings.baseUrl = TestpressCourse.shared.baseURL
                    self.clearCache()
                    DBManager<InstituteSettings>().addData(objects: [settings])
                }
                print(instituteSettings.is)
                completion(instituteSettings, error)
            }
        )
    }

    private func clearCache() {
        DBManager<InstituteSettings>().deleteAllFromDatabase()
    }
}
