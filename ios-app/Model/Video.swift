//
//  Video.swift
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


class Video: DBModel {
    @objc dynamic var url: String = ""
    @objc dynamic var id: Int = -1
    @objc dynamic var title: String = ""
    @objc dynamic var embedCode: String = ""
    @objc dynamic var isDomainRestricted: Bool = false
    @objc dynamic var duration: String = ""

    var streams = List<Stream>()

    
    func getHlsUrl() -> String {
        let hls = self.streams.first{
            $0.format == "HLS"
        }
        return hls?.url ?? self.url
    }
    
    override public static func primaryKey() -> String? {
        return "id"
    }


    public override func mapping(map: Map) {
        url <- map["url"]
        id <- map["id"]
        title <- map["title"]
        embedCode <- map["embed_code"]
        streams <- (map["streams"], ListTransform<Stream>())
        isDomainRestricted <- map["is_domain_restricted"]
        duration <- (map["duration"], StringTransform())
    }
}
