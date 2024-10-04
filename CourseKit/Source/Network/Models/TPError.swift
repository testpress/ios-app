//
//  TPError.swift
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

import UIKit
import Alamofire
import Sentry


public class TPError: Error {
    
    /// Identifies the event kind which triggered TestpressError.
    public enum Kind {
        case
        /// No internet, cannot communicate to the server.
        network,
        /// HTTP status code 403 was received from the server.
        unauthenticated,
        /// A non-200 HTTP status code was received from the server.
        http,
        custom,
        /// All other errors
        unexpected
    }
    
    /// HTTP status code for error.
    public let statusCode: Int
    
    /// Human readable message which corresponds to the error.
    public var message: String?
    
    public var response: HTTPURLResponse?
    
    public var error_detail: String?
    public var error_code: String?
    
    /// Identifies the event kind which triggered this error
    public var kind: Kind
    
    public init(message: String? = nil, response: HTTPURLResponse? = nil, kind: Kind) {
        self.statusCode = response?.statusCode ?? -1
        self.message = message
        self.response = response
        self.kind = kind


        if isCustomError() {
            let error = self.getErrorBodyAs(type: TestpressAPIError.self)?.detail
            self.populateErrorData(code: error?.error_code, detail: error?.message)
        } else if let error_detail = self.getErrorBodyAs(type: ApiError.self) {
            self.populateErrorData(code: error_detail.error_code, detail: error_detail.detail)
        }
        
    }
    
    func isCustomError() -> Bool {
        let error = self.getErrorBodyAs(type: TestpressAPIError.self)
        return error != nil && error?.detail?.message != nil
    }
    
    func populateErrorData(code: String?, detail: String?) {
        self.kind = Kind.custom
        self.error_detail = detail
        self.error_code = code
    }
    
    public func isNetworkError() -> Bool {
        return kind == .network;
    }
    
    public func isClientError() -> Bool {
        return statusCode >= 400 && statusCode < 500;
    }
    
    public func isServerError() -> Bool {
        return statusCode >= 500 && statusCode < 600;
    }
    
    public func getErrorBodyAs<T: TestpressModel>(type: T.Type) -> T? {
        return TPModelMapper<T>().mapFromJSON(json: message!)
    }
    
    public func logErrorToSentry() {
        let event = Event(level: .error)
        event.message = SentryMessage(formatted: self.message ?? "Some error occured")
        event.extra = [
            "statusCode": self.statusCode,
            "error_detail": self.error_detail ?? "",
            "error_code": self.error_code ?? "",
            "kind": "\(self.kind)"
        ]
        
        SentrySDK.capture(event: event)
    }
}


