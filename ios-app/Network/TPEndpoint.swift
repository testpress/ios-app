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
    case createAttempt
    case getQuestions
    case sendHeartBeat
    case saveAnswer
    case endExam
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .authenticateUser:
            return .post
        case .getExams:
            return .get
        case .createAttempt:
            return .post
        case .getQuestions:
            return .get
        case .sendHeartBeat:
            return .put
        case .saveAnswer:
            return .put
        case .endExam:
            return .put
        }
    }
    
    var urlPath: String {
        switch self {
        case .authenticateUser:
            return "/api/v2.2/auth-token/"
        case .getExams:
            return "/api/v2.2/exams/"
        case .sendHeartBeat:
            return "heartbeat/"
        case .endExam:
            return "end/"
        default:
            return ""
        }
    }
}

struct TPEndpointProvider {
    var endpoint: TPEndpoint
    var url: String
    var queryParams: [String: String]
    
    init(_ endpoint: TPEndpoint, url: String = "",
         queryParams: [String: String] = [String: String]()) {
        
        self.endpoint = endpoint
        self.url = url
        self.queryParams = queryParams
    }
    
    func getUrl() -> String {
        // If the given url is empty, use base url with url path
        var url = self.url.isEmpty ? Constants.BASE_URL + endpoint.urlPath : self.url
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
