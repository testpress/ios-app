//
//  ExamPager.swift
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

class ExamPager: TPBasePager<Exam> {
    
    var subclass: String!
    var accessCode: String!
    
    init(subclass: String) {
        self.subclass = subclass
        super.init()
    }
    
    override init() {
        super.init()
    }
    
    override func getItems(page: Int) {
        queryParams.updateValue(String(page), forKey: Constants.PAGE)
        if accessCode != nil {
            let url = Constants.BASE_URL + TPEndpoint.getAccessCodeExams.urlPath + accessCode
                + TPEndpoint.examsPath.urlPath
            
            let endpointProvider = TPEndpointProvider(.getAccessCodeExams, url: url,
                                                      queryParams: queryParams)
            
            TPApiClient.getExams(endpointProvider: endpointProvider, completion: resonseHandler!)
            return
        }
        queryParams.updateValue(subclass, forKey: Constants.STATE)
        TPApiClient.getExams(
            endpointProvider: TPEndpointProvider(.getExams, queryParams: queryParams),
            completion: resonseHandler!
        )
    }
    
    override func getId(resource: Exam) -> Int {
        return resource.id
    }
    
}
