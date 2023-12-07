//
//  Language.swift
//  ios-app
//
//  Created by Prithuvi on 01/12/23.
//  Copyright © 2023 Testpress. All rights reserved.
//

import ObjectMapper
import Realm
import RealmSwift

class Language: DBModel {
        
    @objc var code: String = ""
    @objc var title: String = ""
    
    public override func mapping(map: ObjectMapper.Map) {
        code <- map["code"]
        title <- map["title"]
    }

}


