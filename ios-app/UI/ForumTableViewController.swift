//
//  ForumTableViewController.swift
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

class ForumTableViewController: TPBasePagedTableViewController<Post> {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(pager: PostPager(endpoint: .getForum), coder: aDecoder)
    }
    
    // MARK: - Table view data source
    override func tableViewCell(cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.FORUM_TABLE_VIEW_CELL, for: indexPath) as! ForumTableViewCell
        
        cell.initCell(items[indexPath.row], viewController: self)
        return cell
    }
    
    override func setEmptyText() {
        emptyView.setValues(image: Images.DiscussionFlatIcon.image, title: Strings.NO_FORUM_POSTS,
                            description: Strings.NO_FORUM_POSTS_DESCRIPTION)
    }
    
    func filter(dict: [String: Any]) {
        self.pager.reset()
        for (k, v) in dict {
            self.pager.queryParams.updateValue(v as! String, forKey: k)
        }
        self.refreshWithProgress()
    }
    
    func search(searchString: String) {
        self.pager.reset()
        self.pager.queryParams.updateValue(searchString, forKey: "search")
        self.refreshWithProgress()
    }
}
