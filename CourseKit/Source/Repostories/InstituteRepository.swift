//
//  InstituteRepository.swift
//  CourseKit
//
//  Created by Testpress on 08/10/24.
//  Copyright © 2024 Testpress. All rights reserved.
//

import Foundation
import RealmSwift

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
                completion(instituteSettings, error)
            }
        )
    }

    private func clearCache() {
        DBManager<InstituteSettings>().deleteAllFromDatabase()
    }
    
    public func observeSettingsChanges(
        completion: @escaping (InstituteSettings?) -> Void
    ) -> NotificationToken? {
        return DBManager<InstituteSettings>().getResultsFromDB().observe { changes in
            switch changes {
            case .initial(let settings), .update(let settings, _, _, _):
                if settings.isNotEmpty {
                    completion(settings.first)
                }
            case .error(let error):
                print("Error observing Realm objects: \(error)")
            }
        }
    }
}
