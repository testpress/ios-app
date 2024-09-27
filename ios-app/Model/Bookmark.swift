//
//  Bookmark.swift
//  ios-app
//
//  Copyright © 2018 Testpress. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import ObjectMapper
import Realm
import RealmSwift
import TTGSnackbar
import UIKit
import Foundation

class Bookmark: DBModel {
    
    @objc dynamic var folder: String? = nil
    @objc dynamic var folderId = 0
    @objc dynamic var objectId = 0
    @objc dynamic var contentTypeId = 0
    @objc dynamic var modified: String = ""
    @objc dynamic var created: String = ""
    @objc dynamic var active = true
    
    var bookmarkedObject: Any!
    
    
    override class func ignoredProperties() -> [String] {
        return ["bookmarkedObject"]
    }
    
    public override func mapping(map: ObjectMapper.Map) {
        id <- map["id"]
        folder <- map["folder"]
        folderId <- map["folder_id"]
        objectId <- map["object_id"]
        contentTypeId <- map["content_type_id"]
        modified <- map["modified"]
        created <- map["created"]
        active <- map["active"]
    }
    
    override public static func primaryKey() -> String? {
        return "id"
    }
    
}
