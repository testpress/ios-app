//
//  GapFillResponse.swift
//  ios-app
//
//  Created by Karthik on 15/04/21.
//  Copyright © 2021 Testpress. All rights reserved.
//

import ObjectMapper
import RealmSwift


class GapFillResponse: DBModel {
    @objc dynamic var order: Int = -1
    @objc dynamic var answer: String = "";
    
    public override func mapping(map: Map) {
        order <- map["order"]
        answer <- map["answer"]
    }
    
    public static func create(order: Int, answer: String) -> GapFillResponse{
        let response = GapFillResponse()
        response.order = order
        response.answer = answer
        return response
    }
}
