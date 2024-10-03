//
//  Language.swift
//  ios-app
//
//  Created by Prithuvi on 01/12/23.
//  Copyright © 2023 Testpress. All rights reserved.
//

import ObjectMapper
import RealmSwift
import Foundation

class Language: DBModel {
        
    @objc dynamic var code: String = ""
    @objc dynamic var title: String = ""
    
    public override func mapping(map: ObjectMapper.Map) {
        code <- map["code"]
        title <- map["title"]
    }

}


