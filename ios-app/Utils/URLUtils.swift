//
//  URLUtils.swift
//  ios-app
//
//  Created by Karthik on 05/06/20.
//  Copyright © 2020 Testpress. All rights reserved.
//

import Foundation

class URLUtils {
    static func convertURLSchemeToHttps(url: URL) -> URL {
        var urlComponents = URLComponents(
            url: url,
            resolvingAgainstBaseURL: false
        )
        urlComponents!.scheme = "https"
        return urlComponents!.url!
    }
}
