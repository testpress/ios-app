//
//  ChapterContentDetailViewModel.swift
//  ios-app
//
//  Created by Testpress on 24/05/24.
//  Copyright © 2024 Testpress. All rights reserved.
//

import Foundation
import CourseKit

class ChapterContentDetailViewModel {
    var content: Content
    var contentAttemptCreationDelegate: ContentAttemptCreationDelegate?
    
    init(_ content: Content, _ contentAttemptCreationDelegate: ContentAttemptCreationDelegate?) {
        self.content = content
        self.contentAttemptCreationDelegate = contentAttemptCreationDelegate
    }
    
    func createContentAttempt() {
        TPApiClient.request(
            type: ContentAttempt.self,
            endpointProvider: TPEndpointProvider(.post, url: content.getAttemptsUrl())
        ) { contentAttempt, error in
            if let error = error {              
                debugPrint(error.message ?? "No error")
                debugPrint(error.kind)
                return
            }
            
            if self.content.attemptsCount == 0 {
                self.contentAttemptCreationDelegate?.newAttemptCreated()
            }
        }
    }
}
