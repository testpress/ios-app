//
//  File.swift
//  ios-app
//
//  Created by Prithuvi on 19/12/23.
//  Copyright © 2023 Testpress. All rights reserved.
//

import ObjectMapper
import Foundation

public class AttemptAnswerTranslation: DBModel {
    @objc dynamic public var textHtml: String = ""
    
    public override func mapping(map: Map) {
        textHtml <- map["text_html"]
        id <- map["id"]
    }
    
    override public static func primaryKey() -> String? {
        return "id"
    }
}
