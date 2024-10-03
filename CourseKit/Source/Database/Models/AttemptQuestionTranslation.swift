//
//  AttemptQuestionTranslation.swift
//  ios-app
//
//  Created by Prithuvi on 19/12/23.
//  Copyright © 2023 Testpress. All rights reserved.
//

import ObjectMapper
import RealmSwift
import Foundation

public class AttemptQuestionTranslation: DBModel {
    
    @objc dynamic public var questionHtml: String?;
    @objc dynamic public var direction: DirectionTranslation?
    @objc dynamic public var explanationHtml: String?
    @objc dynamic public var language: String?
    public var answers = List<AttemptAnswerTranslation>()
    
    override public static func primaryKey() -> String? {
        return "id"
    }

    public override func mapping(map: ObjectMapper.Map) {
        id <- map["id"]
        questionHtml <- map["question_html"]
        direction <- map["direction"]
        explanationHtml <- map["explanation"]
        answers <- (map["answers"], ListTransform<AttemptAnswerTranslation>())
        language <- map["language"]
    }
    
    let transform = TransformOf<Int, Int>(fromJSON: { (value: Int?) -> Int? in
        return Int(value ?? -1)
    }, toJSON: { (value: Int?) -> Int? in
        return Int(value ?? -1)
    })

}

