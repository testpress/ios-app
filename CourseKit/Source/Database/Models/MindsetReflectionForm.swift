//
//  PreExamReflectionForm.swift
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
}
