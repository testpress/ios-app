//
//  UserUploadedFile.swift

import ObjectMapper
import RealmSwift


class UserUploadedFile: DBModel {
    @objc dynamic var id = 0
    @objc dynamic var path: String = ""
    @objc dynamic var url: String = ""
    
    public override func mapping(map: Map) {
        id <- map["id"]
        path <- map["path"]
        url <- map["url"]
    }
}
