//
//  File.swift
//  ios-app
//
//  Created by Prithuvi on 19/12/23.
//  Copyright © 2023 Testpress. All rights reserved.
//

import ObjectMapper

class AttemptAnswerTranslation: DBModel {
    @objc dynamic var textHtml: String = ""
    @objc dynamic var isCorrect: Bool = false
    
    public override func mapping(map: Map) {
        textHtml <- map["text_html"]
        id <- map["id"]
        isCorrect <- map["is_correct"]
    }
    
    override public static func primaryKey() -> String? {
        return "id"
    }
}
