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
        return self.convertURLScheme(url: url, scheme: "https")
    }
    
    static func convertURLScheme(url: URL, scheme: String) -> URL {
        var urlComponents = URLComponents(
            url: url,
            resolvingAgainstBaseURL: false
        )
        urlComponents!.scheme = scheme
        return urlComponents!.url!
    }
    
    static func changeDomain(url: URL, newDomain: String) -> URL {
        var urlComponents = URLComponents(
            url: url,
            resolvingAgainstBaseURL: false
        )
        urlComponents!.host = URLComponents(string: newDomain)!.host
        return urlComponents!.url!
    }
}
