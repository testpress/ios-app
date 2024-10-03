//
//  Content.swift
//  ios-app
//
//  Created by Testpress on 03/10/24.
//  Copyright © 2024 Testpress. All rights reserved.
//

import Foundation
import CourseKit

extension Content {
    public static func fetchContent(url:String, completion: @escaping(Content?, TPError?) -> Void) {
        TPApiClient.request(
            type: Content.self,
            endpointProvider: TPEndpointProvider(.get, url: url),
            completion: {
                content, error in
                if let error = error {
                    debugPrint(error.message ?? "No error")
                    debugPrint(error.kind)
                } else {
                    let content: Content = content!
                    print("Content : \(content)")
                }
                completion(content, error)
        })
    }
    
    public func getAttemptsUrl() -> String {
        var url = String(format: "%@%@%d/attempts/", Constants.BASE_URL , TPEndpoint.getContents.urlPath, self.id)
        url = url.replacingOccurrences(of: "v2.3", with: "v2.2.1")
        return url
    }
    
    public func getContentType() -> ContentTypeEnum {
        return ContentTypeEnum(rawValue: contentType) ?? .Unknown
    }
    
    public func getUrl() -> String {
        var contentDetailUrl = String(format: "%@/api/v2.4/contents/%d/", Constants.BASE_URL , self.id)
        return url.isEmpty ? contentDetailUrl : url
    }
}
