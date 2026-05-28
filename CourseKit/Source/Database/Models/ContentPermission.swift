//
//  ContentPermission.swift
//  CourseKit
//
//  Copyright © 2024 Testpress. All rights reserved.
//

import Foundation
import ObjectMapper

public class ContentPermission: TestpressModel {
    public var hasPermission: Bool = false
    public var nextRetakeTime: String?

    public required init?(map: Map) {}

    public func mapping(map: Map) {
        hasPermission <- map["has_permission"]
        nextRetakeTime <- map["next_retake_time"]
    }
}