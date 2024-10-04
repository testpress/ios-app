//
//  ContentAttempt.swift
//  ios-app
//
//  Created by Testpress on 04/10/24.
//  Copyright © 2024 Testpress. All rights reserved.
//

import Foundation
import CourseKit

extension ContentAttempt {
    public func getEndAttemptUrl() -> String {
        return Constants.BASE_URL + TPEndpoint.contentAttempts.urlPath + "\(id!)/" +
            TPEndpoint.endExam.urlPath;
    }
}
