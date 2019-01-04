//
//  ContentsTableViewController.swift
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

protocol ContentAttemptCreationDelegate {
    func newAttemptCreated()
}

class ContentsTableViewController: TPBasePagedTableViewController<Content>,
    ContentAttemptCreationDelegate {
    
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    
    var contentsUrl: String!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(pager: ContentPager(), coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarItem.title = title
        (pager as! ContentPager).url = contentsUrl
    }
 
    // MARK: - Table view data source
    override func tableViewCell(cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CONTENT_TABLE_VIEW_CELL,
                                                 for: indexPath) as! ContentsTableViewCell
        
        cell.initCell(position: indexPath.row, viewController: self)
        return cell
    }
    
    override func onLoadFinished(items: [Content]) {
        super.onLoadFinished(items: items.sorted(by: { $0.order! < $1.order! }))
    }
    
    func newAttemptCreated() {
        items.removeAll()
    }
    
    override func setEmptyText() {
        emptyView.setValues(image: Images.LearnFlatIcon.image, title: Strings.NO_ITEMS_EXIST,
                            description: Strings.NO_CONTENT_DESCRIPTION)
    }
    
    @IBAction func back() {
        dismiss(animated: true, completion: nil)
    }
    
}
