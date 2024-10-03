//
//  BookmarkFolderPager.swift
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

class BookmarkFolderPager: BasePager<BookmarksListResponse, BookmarkFolder> {
    
    var folders = [Int: BookmarkFolder]()
    
    override func getResponse(page: Int) {
        queryParams.updateValue(String(page), forKey: Constants.PAGE)
        TPApiClient.getListItems(
            type: BookmarksListResponse.self,
            endpointProvider: TPEndpointProvider(.bookmarkFolders, queryParams: queryParams),
            completion: responseHandler!
        )
    }
    
    override func getItems(_ resultResponse: BookmarksListResponse) -> [BookmarkFolder] {
        return resultResponse.folders
    }
    
    override func getId(resource: BookmarkFolder) -> Int {
        return resource.id
    }
    
}
