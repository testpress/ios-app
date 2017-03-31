//
//  TPEndpoint.swift
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


import Foundation
import Alamofire

enum TPEndpoint {
    
    case authenticateUser
    case getExams
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .authenticateUser:
            return .post
        case .getExams:
            return .get
        }
    }
}

struct TPEndpointProvider {
    var endpoint: TPEndpoint
    var queryParams: [String: String]
    
    init(_ endpoint: TPEndpoint, queryParams: [String: String] = [String: String]()) {
        self.endpoint = endpoint
        self.queryParams = queryParams
    }
    
    func getUrl() -> String {
        var urlPath: String
        switch endpoint {
        case .authenticateUser:
            urlPath = "/api/v2.2/auth-token/"
        case .getExams:
            urlPath = "/api/v2.2/exams/"
        }
        var url = Constants.BASE_URL + urlPath
        if !queryParams.isEmpty {
            url = url + "?"
            for (i, queryParam) in queryParams.enumerated() {
                url = url + queryParam.key + "=" + queryParam.value
                print("i:\(i)")
                if queryParams.count != (i + 1) {
                    url = url + "&"
                }
            }
        }
        return url
    }
    
}
