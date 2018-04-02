//
//  RecentPostTableViewController.swift
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
import TTGSnackbar
import UIKit

class RecentPostTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,
    UIScrollViewDelegate {
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var categoryLayout: UIView!
    @IBOutlet weak var categoryLayoutHeightConstraint: NSLayoutConstraint!
    
    var activityIndicator: UIActivityIndicatorView! // Progress bar
    var emptyView: EmptyView!
    var posts = [Post]()
    var pager: TPBasePager<Post>
    var loadingItems: Bool = false
    let bottomGradient = CAGradientLayer()
    var categoryTableViewController: PostCategoriesTableViewController!
    let categoryLayoutHeight: CGFloat = 275
    var categoriesDropDown: PostCategoriesDropDown!
    
    required init(coder aDecoder: NSCoder? = nil) {
        self.pager = PostPager()
        super.init(coder: aDecoder!)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator = UIUtils.initActivityIndicator(parentView: self.view)
        activityIndicator?.center = CGPoint(x: view.center.x, y: view.center.y - 50)
        
        // Set table view backgroud
        emptyView = EmptyView.getInstance()
        tableView.backgroundView = emptyView
        emptyView.frame = tableView.frame
        
        UIUtils.setTableViewSeperatorInset(tableView, size: 15)
        tableView.tableFooterView = UIView()
        
        // Set table view footer as progress spinner
        let pagingSpinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        pagingSpinner.startAnimating()
        pagingSpinner.color = Colors.getRGB(Colors.PRIMARY)
        pagingSpinner.hidesWhenStopped = true
        tableView.tableFooterView = pagingSpinner
        
        tableHeight.constant = scrollView.frame.height
        tableView.isScrollEnabled = false
        scrollView.bounces = false
        tableView.bounces = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        if posts.isEmpty {
            activityIndicator?.startAnimating()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if posts.isEmpty {
            tableView.tableFooterView?.isHidden = true
            pager.reset()
            loadItems()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PostCategoriesSegue" {
            if let viewController = segue.destination as? PostCategoriesTableViewController {
                categoryTableViewController = viewController
                viewController.postCategoryDelegate = self
            }
        }
    }
    
    func loadItems() {
        if loadingItems {
            return
        }
        loadingItems = true
        pager.next(completion: {
            items, error in
            if let error = error {
                debugPrint(error.message ?? "No error")
                debugPrint(error.kind)
                self.handleError(error)
                return
            }
            
            self.posts = Array(items!.values)
            if self.posts.count == 0 {
                self.setEmptyText()
            }
            self.onLoadFinished()
            self.tableView.tableFooterView?.isHidden = true
            self.loadingItems = false
        })
    }
    
    func onLoadFinished() {
        self.tableView.reloadData()
        if (self.activityIndicator?.isAnimating)! {
            self.activityIndicator?.stopAnimating()
        }
    }
    
    func handleError(_ error: TPError) {
        var retryHandler: (() -> Void)?
        if error.kind == .network {
            retryHandler = {
                self.activityIndicator?.startAnimating()
                self.loadItems()
                if self.posts.count == 0 {
                    self.categoryTableViewController.activityIndicator?.startAnimating()
                    self.categoryTableViewController.loadItems()
                }
            }
        }
        let (image, title, description) = error.getDisplayInfo()
        if (activityIndicator?.isAnimating)! {
            activityIndicator?.stopAnimating()
        }
        if posts.count == 0 {
            emptyView.setValues(image: image, title: title, description: description,
                                retryHandler: retryHandler)
        } else {
            TTGSnackbar(message: description, duration: .middle).show()
        }
        tableView.reloadData()
        loadingItems = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            tableView.isScrollEnabled = (self.scrollView.contentOffset.y >= categoryLayoutHeight)
        }
        if scrollView == tableView {
            tableView.isScrollEnabled = (tableView.contentOffset.y > 0) || categoryLayout.isHidden
        }
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if posts.count == 0 {
            tableView.backgroundView?.isHidden = false
        } else {
            tableView.backgroundView?.isHidden = true
        }
        return posts.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableViewCell(cellForRowAt: indexPath)
        
        // Load more items on scroll to bottom
        if indexPath.row >= (posts.count - 4) && !loadingItems {
            if pager.hasMore {
                tableView.tableFooterView?.isHidden = false
                loadItems()
            } else {
                tableView.tableFooterView?.isHidden = true
            }
        }
        return cell
    }
    
    func tableViewCell(cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.POST_TABLE_VIEW_CELL, for: indexPath) as! PostTableViewCell
        
        cell.initCell(posts[indexPath.row], viewController: self)
        return cell
    }
    
    // Set frames of the views in this method to support both portrait & landscape view
    override func viewDidLayoutSubviews() {
        UIUtils.updateBottomShadow(bottomShadowView: shadowView,
                                   bottomGradient: bottomGradient)
    }
    
    func setEmptyText() {
        emptyView.setValues(image: Images.NewsFlatIcon.image, title: Strings.NO_POSTS,
                            description: Strings.NO_POSTS_DESCRIPTION)
    }
    
    @IBAction func showProfileDetails(_ sender: UIBarButtonItem) {
        UIUtils.showProfileDetails(self)
    }
    
}

extension RecentPostTableViewController: PostCategoryDelegate {
    
    func onLoadedCategories(_ categories: [Category]) {
        if !categories.isEmpty {
            categoriesDropDown = PostCategoriesDropDown(categories: categories,
                                                        navigationItem: navigationItem)
            
            categoriesDropDown.dropDown.selectionAction = { (index: Int, item: String) in
                
                DispatchQueue.main.async {
                    self.categoriesDropDown.dropDown.clearSelection()
                }
                let storyboard = UIStoryboard(name: Constants.POST_STORYBOARD, bundle: nil)
                let navigationController = storyboard.instantiateViewController(withIdentifier:
                    Constants.POSTS_LIST_NAVIGATION_CONTROLLER) as! UINavigationController
                
                let viewController =
                    navigationController.viewControllers.first as! PostTableViewController
                
                viewController.category =
                    self.categoriesDropDown.getCategory(withSlug: item, from: categories)
                
                viewController.categories = categories
                self.present(navigationController, animated: true, completion: nil)
            }
        } else {
            navigationItem.titleView = nil
            navigationItem.title = Strings.ARTICLES
        }
    }
    
    func onError(_ error: TPError) {
        handleError(error)
        onEmptyCategories()
    }
    
    func onEmptyCategories() {
        categoryLayout.isHidden = true
        categoryLayoutHeightConstraint.constant = 0
        tableView.isScrollEnabled = true
    }
    
    func showCategories() {
        categoryLayout.isHidden = false
        categoryLayoutHeightConstraint.constant = categoryLayoutHeight
    }
    
}
