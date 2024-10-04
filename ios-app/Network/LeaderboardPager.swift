//
//  LeaderboardPager.swift
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
import CourseKit

class LeaderboardPager: TPBasePager<Reputation> {
    
    override func getItems(page: Int) {
        queryParams.updateValue(String(page), forKey: Constants.PAGE)
        queryParams.updateValue(String(20), forKey: Constants.PAGE_SIZE)
        TPApiClient.getListItems(
            endpointProvider: TPEndpointProvider(.getLeaderboard, queryParams: queryParams),
            completion: resonseHandler!,
            type: Reputation.self
        )
    }
    
    override func getId(resource: Reputation) -> Int {
        return resource.id
    }
    
}
