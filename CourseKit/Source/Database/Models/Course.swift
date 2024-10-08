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
import RealmSwift
import Foundation

public class Course: DBModel {
    
    @objc dynamic public var url: String = ""
    @objc dynamic public var title: String = ""
    @objc dynamic public var image: String = ""
    @objc dynamic public var modified: String = ""
    @objc dynamic public var modifiedDate: Double = 0
    @objc dynamic public var contentsUrl: String = ""
    @objc dynamic public var chaptersUrl: String = ""
    @objc dynamic public var slug: String = ""
    @objc dynamic public var trophiesCount = 0
    @objc dynamic public var chaptersCount = 0
    @objc dynamic public var contentsCount = 0
    @objc dynamic public var order = 0
    @objc dynamic public var active = true
    @objc dynamic public var external_content_link: String = ""
    @objc dynamic public var external_link_label: String = ""
    @objc dynamic public var allowCustomTestGeneration = false
    @objc dynamic public var expiryDate: String? = ""
    public var tags = List<String>()

    public override func mapping(map: ObjectMapper.Map) {
        url <- map["url"]
        id <- map["id"]
        title <- map["title"]
        image <- map["image"]
        modified <- map["modified"]
        modifiedDate = 0
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
        allowCustomTestGeneration <- map["allow_custom_test_generation"]
        expiryDate <- map["expiry_date"]
        tags <- (map["tags"], StringArrayTransform())
    }
    
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    public func getFormattedExpiryDate() -> String {
        do {
            guard let expiryDate = self.expiryDate, !expiryDate.isEmpty else {
                return ""
            }
                
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "yyyy-MM-dd"
                
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "MMM dd, yyyy"
                
            if let date = inputFormatter.date(from: expiryDate) {
                return "Valid till " + outputFormatter.string(from: date)
            } else {
                return ""
            }
        } catch {
            print("Error parsing date: \(error.localizedDescription)")
            return ""
        }
    }
}
