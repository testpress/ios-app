//
//  AttemptItem.swift
//  ios-app
//
//  Created by Testpress on 03/10/24.
//  Copyright © 2024 Testpress. All rights reserved.
//

import Foundation
import CourseKit

extension AttemptItem {
    public func getSaveUrl() -> String {
        return String(format: "%@/api/v2.4/attempts/%d/questions/%d/", Constants.BASE_URL , self.attemptId, self.examQuestionId)
    }
    
    func clearLocalFiles() {
        DBManager<AttemptItem>().write {
            self.localFiles.removeAll()
        }
    }

    func saveUploadedFilePath(with uploadedPath: String) {
        let userFileResponse = UserFileResponse.create(uploadedPath: uploadedPath)
        DBManager<AttemptItem>().write {
            self.localFiles.append(userFileResponse)
        }
    }
}
