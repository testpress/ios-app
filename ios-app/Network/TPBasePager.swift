//
//  TPBasePager.swift
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

class TPBasePager<T: Mappable> {
    
    var response: TPApiResponse<T>?
    
    /**
     * Next page to request
     */
    var page: Int = 1
    
    /**
     * All resources retrieved
     */
    var resources = OrderedDictionary<Int, T>()
    
    /**
     * Query Params to be passed
     */
    public var queryParams = [String: String]()
    
    /**
     * Are more pages available?
     */
    var hasMore: Bool = false
    
    var completion: ((OrderedDictionary<Int, T>?, TPError?) -> Void)? = nil
    
    var resonseHandler: ((TPApiResponse<T>?, TPError?) -> Void)? = nil
    
    init() {
        resonseHandler = { response, error in
            if let error = error {
                self.hasMore = false;
                self.completion!(self.resources, error)
            } else {
                self.response = response
                self.onSuccess()
            }
        }
    }
    
    func reset() {
        page = 1
        resources.removeAll()
        queryParams.removeAll()
        response = nil
        hasMore = true
    }
    
    func getItems(page: Int) {
        queryParams.updateValue(String(page), forKey: Constants.PAGE)
    }
    
    public func next(completion: @escaping (OrderedDictionary<Int, T>?, TPError?) -> Void) {
        self.completion = completion
        getItems(page: page);
    }
    
    func onSuccess() {
        let resourcePage: [T] = (response?.results)!;
        #if DEBUG
            print("response?.next:" + (response!.next))
            print("response?.previous:" + (response!.previous))
            print("response?.count:"+String(response!.count!))
        #endif
        let emptyPage = resourcePage.isEmpty;
        for resource in resourcePage {
            let resource: T? = register(resource: resource);
            if resource == nil {
                continue;
            }
            resources[getId(resource: resource!)] = resource!
        }
        page += 1;
        hasMore = hasNext() && !emptyPage;
        #if DEBUG
            print("self.hasMore:\(hasMore)")
            print("hasNext():\(hasNext())")
        #endif
        completion!(resources, nil)
    }
    
    func register(resource: T) -> T? {
        return resource;
    }
    
    func getId(resource: T) -> Int {
        return -1
    }

    func hasNext() -> Bool {
        return response == nil || (response != nil && !(response!.next.isEmpty));
    }
}



