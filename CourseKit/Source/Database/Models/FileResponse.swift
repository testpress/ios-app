//
//  FileResponse.swift
//  ios-app
//
//  Created by Testpress on 12/07/24.
//  Copyright © 2024 Testpress. All rights reserved.
//

import Foundation
import ObjectMapper
import Foundation

public class UserFileResponse: DBModel {
    @objc dynamic public var path: String = ""
    @objc dynamic public var url: String = ""
    @objc dynamic public var pdfPreviewUrl: String?
        
    override class public func ignoredProperties() -> [String] {
        return ["id"]
    }
    
    override public func mapping(map: Map) {
        id <- map["id"]
        path <- map["path"]
        url <- map["url"]
        pdfPreviewUrl <- map["pdf_preview_url"]
    }
    
    public static func create(uploadedPath: String) -> UserFileResponse{
        let response = UserFileResponse()
        response.path = uploadedPath
        return response
    }
}
