//
//  PostTableViewController.swift
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

import DropDown
import UIKit

class PostTableViewController: TPBasePagedTableViewController<Post> {
    
    var category: Category!
    var categories: [Category]!
    var categoriesDropDown: PostCategoriesDropDown!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(pager: PostPager(), coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        (pager as! PostPager).category = category
        categoriesDropDown = PostCategoriesDropDown(category: category, categories: categories,
                                                    navigationItem: navigationItem)
        
        categoriesDropDown.dropDown.selectionAction = { (index: Int, item: String) in
            DispatchQueue.main.async {
                self.categoriesDropDown.dropDown.selectRow(index)
            }
            if item == self.category.slug {
                return
            }
            
            self.category =
                self.categoriesDropDown.getCategory(withSlug: item, from: self.categories)
            
            self.categoriesDropDown.titleButton.setTitle(self.category.name, for: .normal)
            (self.pager as! PostPager).category = self.category
            self.pager.reset()
            self.items = []
            self.tableView.reloadData()
            self.activityIndicator?.startAnimating()
            self.loadItems()
        }
        
        for (index, category) in categories.enumerated() {
            if category.slug == self.category.slug {
                categoriesDropDown.dropDown.selectRow(index)
                break
            }
        }
    }
    
    // MARK: - Table view data source
    override func tableViewCell(cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.POST_TABLE_VIEW_CELL, for: indexPath) as! PostTableViewCell
        
        cell.initCell(items[indexPath.row], viewController: self)
        return cell
    }
    
    override func setEmptyText() {
        emptyView.setValues(image: Images.NewsFlatIcon.image, title: Strings.NO_POSTS,
                            description: Strings.NO_POSTS_DESCRIPTION)
    }
    
    @IBAction func back() {
        dismiss(animated: true, completion: nil)
    }
    
}
