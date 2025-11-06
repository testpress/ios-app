//
//  BasePager.swift
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

import Alamofire
import ObjectMapper

// Base Pager for V4 API's
public class BasePager<T: TestpressModel, L: TestpressModel> {
    
    public var response: ApiResponse<T>?
    
    /**
     * Next page to request
     */
    public var page: Int = 1
    
    /**
     * All resources retrieved
     */
    public var resources = OrderedDictionary<Int, L>()
    
    /**
     * Query Params to be passed
     */
    public var queryParams = [String: String]()
    
    /**
     * Are more pages available?
     */
    public var hasMore: Bool = false
    
    public var completion: ((OrderedDictionary<Int, L>?, TPError?) -> Void)? = nil
    
    public var responseHandler: ((ApiResponse<T>?, TPError?) -> Void)? = nil
    
    public init() {
        responseHandler = { response, error in
            if let error = error {
                self.hasMore = false;
                self.completion!(self.resources, error)
            } else {
                self.response = response
                self.onSuccess()
            }
        }
    }
    
    public func clearValues() {
        resources.removeAll()
    }
    
    public func reset() {
        page = 1
        clearValues()
        queryParams.removeAll()
        response = nil
        hasMore = true
    }
    
    public func next(completion: @escaping(OrderedDictionary<Int, L>?, TPError?) -> Void) {
        self.completion = completion
        getResponse(page: page);
    }
    
    public func onSuccess() {
        let resourcePage: [L] = getItems(response!.results)
        #if DEBUG
        print("response?.next:" + (response!.next))
        print("response?.previous:" + (response!.previous))
        print("response?.count:"+String(response!.count))
        #endif
        let emptyPage = resourcePage.isEmpty
        for resource in resourcePage {
            let resource: L? = register(resource: resource);
            if resource == nil {
                continue;
            }
            resources[getId(resource: resource!)] = resource!
        }
        page += 1;
        hasMore = hasNext() && !emptyPage
        #if DEBUG
        print("self.hasMore:\(hasMore)")
        print("hasNext():\(hasNext())")
        #endif
        completion!(self.resources, nil)
    }
    
    public func getResponse(page: Int) {
        queryParams.updateValue(String(page), forKey: Constants.PAGE)
    }
    
    public func getItems(_ resultResponse: T) -> [L] {
        return []
    }
    
    public func register(resource: L) -> L? {
        return resource
    }
    
    public func getId(resource: L) -> Int {
        return -1
    }
    
    public func hasNext() -> Bool {
        return response == nil || (response != nil && !(response!.next.isEmpty));
    }
    
    public func resetValues(of items: [[Int: Any]]) {
        for item in items {
            var item = item
            item.removeAll()
        }
    }
    
}
