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
}
