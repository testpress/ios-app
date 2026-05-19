//
//  AnalyticsLoader.swift
//  ios-app
//
//  Copyright © 2024 Testpress. All rights reserved.
//

import Foundation
import CourseKit

class AnalyticsLoader {

    private var pager: SubjectPager?
    private var isLoading = false

    func load(analyticsUrl: String, completion: @escaping ([Subject]?, TPError?) -> Void) {
        guard !isLoading else { return }
        isLoading = true

        let pager = SubjectPager(analyticsUrl, parentSubjectId: "null")
        self.pager = pager
        fetchNextPage(pager: pager, completion: completion)
    }

    private func fetchNextPage(pager: SubjectPager, completion: @escaping ([Subject]?, TPError?) -> Void) {
        pager.next { [weak self] items, error in
            guard let self = self else { return }

            if let error = error {
                self.isLoading = false
                completion(nil, error)
                return
            }

            if pager.hasMore {
                self.fetchNextPage(pager: pager, completion: completion)
            } else {
                self.isLoading = false
                let subjects = items.map { Array($0.values) } ?? []
                completion(subjects, nil)
            }
        }
    }

    func reset() {
        pager = nil
        isLoading = false
    }

}
