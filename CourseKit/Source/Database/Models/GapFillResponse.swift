//
//  GapFillResponse.swift
//  ios-app
//
//  Created by Karthik on 15/04/21.
//  Copyright © 2021 Testpress. All rights reserved.
//

import ObjectMapper
import Foundation


public class GapFillResponse: DBModel {
    @objc dynamic public var order: Int = -1
    @objc dynamic public var answer: String = "";
    
    public override func mapping(map: ObjectMapper.Map) {
        order <- map["order"]
        answer <- map["answer"]
    }
    
    override class public func ignoredProperties() -> [String] {
        return ["id"]
    }
    
    public static func create(order: Int, answer: String) -> GapFillResponse{
        let response = GapFillResponse()
        response.order = order
        response.answer = answer
        return response
    }
}
