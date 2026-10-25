//
//  MindsetReflectionForm.swift
//  CourseKit
//

import ObjectMapper
import RealmSwift
import Foundation

public class MindsetReflectionForm: DBModel {
    @objc public dynamic var submissionMandatory: Bool = false
    
    public override func mapping(map: ObjectMapper.Map) {
        id <- map["id"]
        submissionMandatory <- map["submission_mandatory"]
    }
    
    override public static func primaryKey() -> String? {
        return "id"
    }

    public func getSSOUrl(examId: Int) -> String {
        return "&next=/exam-mindset/\(examId)/reflection/\(id)/"
    }

    public func getPostExamSSOUrl(examId: Int, attemptId: Int) -> String {
        return "&next=/exam-mindset/\(examId)/reflection/\(id)/userexam/\(attemptId)/"
    }
}
