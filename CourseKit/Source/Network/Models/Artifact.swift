//
//  Artifact.swift
//  CourseKit
//
//  Copyright © 2024 Testpress. All rights reserved.
//

import ObjectMapper

public class Artifact: Mappable {
    public var id: Int = 0
    public var name: String = ""
    public var url: String = ""
    public var accessibleWithoutAttempt: Bool = true

    public required init?(map: Map) {}

    public func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        url <- map["url"]
        accessibleWithoutAttempt <- map["accessible_without_attempt"]
    }
}
