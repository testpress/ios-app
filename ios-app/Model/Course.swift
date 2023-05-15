//
//  Course.swift
//  ios-app
//
//  Copyright © 2017 Testpress. All rights reserved.
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

class Course: DBModel {
    
    @objc dynamic var url: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var image: String = ""
    @objc dynamic var modified: String = ""
    @objc dynamic var modifiedDate: Double = 0
    @objc dynamic var contentsUrl: String = ""
    @objc dynamic var chaptersUrl: String = ""
    @objc dynamic var slug: String = ""
    @objc dynamic var trophiesCount = 0
    @objc dynamic var chaptersCount = 0
    @objc dynamic var contentsCount = 0
    @objc dynamic var order = 0
    @objc dynamic var active = true
    @objc dynamic var external_content_link: String = ""
    @objc dynamic var external_link_label: String = ""
    var tags = List<String>()

    public override func mapping(map: ObjectMapper.Map) {
        url <- map["url"]
        id <- map["id"]
        title <- map["title"]
        image <- map["image"]
        modified <- map["modified"]
        modifiedDate = FormatDate.getDate(from: modified)?.timeIntervalSince1970 ?? 0
        contentsUrl <- map["contents_url"]
        chaptersUrl <- map["chapters_url"]
        slug <- map["slug"]
        trophiesCount <- map["trophies_count"]
        chaptersCount <- map["chapters_count"]
        contentsCount <- map["contents_count"]
        order <- map["order"]
        active <- map["active"]
        external_content_link <- map["external_content_link"]
        external_link_label <- map["external_link_label"]
        tags <- (map["tags"], StringArrayTransform())
    }
    
    override public static func primaryKey() -> String? {
        return "id"
    }
}
