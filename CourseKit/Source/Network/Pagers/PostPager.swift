//
//  PostPager.swift
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

public class PostPager: TPBasePager<Post> {
    
    public let endpoint: TPEndpoint
    public var category: CourseKit.Category!
    
    public init(endpoint: TPEndpoint = .getPosts) {
        self.endpoint = endpoint
        super.init()
    }
    
    public override func getItems(page: Int) {
        queryParams.updateValue("-published_date", forKey: Constants.ORDER)
        queryParams.updateValue(String(page), forKey: Constants.PAGE)
        if category != nil {
            queryParams.updateValue(category.slug, forKey: Constants.CATEGORY)
        }
        TPApiClient.getListItems(
            endpointProvider: TPEndpointProvider(endpoint, queryParams: queryParams),
            completion: resonseHandler!,
            type: Post.self
        )
    }
    
    public override func register(resource post: Post) -> Post? {
        return post.isActive ? post : nil
    }
    
    public override func getId(resource: Post) -> Int {
        return resource.id!
    }
    
}
