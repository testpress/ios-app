//
//  ChaptersViewController.swift
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

class ChaptersViewController:
BaseDBViewController<Chapter> {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var navigationItemBar: UINavigationItem!
    
    var activityIndicator: UIActivityIndicatorView? // Progress bar
    var emptyView: EmptyView!
    var pager: ChapterPager!
    var loadingItems: Bool = false
    var coursesUrl: String!
    var courseId: Int!
    var parentId: Int? = nil
    var firstCallback: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItemBar.title = title
        pager = ChapterPager(coursesUrl: coursesUrl, parentId: parentId)
        activityIndicator = UIUtils.initActivityIndicator(parentView: collectionView)
        activityIndicator?.center = CGPoint(x: view.center.x, y: view.center.y - 50)
        // Set collection view background
        emptyView = EmptyView.getInstance()
        collectionView.dataSource = self
        collectionView.backgroundView = emptyView
        emptyView.frame = collectionView.frame
        self.setStatusBarColor()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showItemsFromDB()
        
        if (items.isEmpty || firstCallback) {
            firstCallback = false
            if (items.isEmpty) {
                activityIndicator?.startAnimating()
            }
            pager.reset()
            loadItems()
        }
    }
    
    override func getItemsFromDB() -> [Chapter] {
        var filterQuery = String(format: "courseId==%d", courseId)
        
        if (parentId != nil) {
            filterQuery += String(format: " AND parentId==%d", parentId!)
        } else {
            filterQuery += String(format: " AND parentId=0")
        }
        
        return DBManager<Chapter>().getItemsFromDB(filteredBy:filterQuery, byKeyPath: "order")
    }
    
    func showItemsFromDB() {
        if (!self.getItemsFromDB().isEmpty) {
            self.items = self.getItemsFromDB()
            self.loadingItems = false
            self.items = self.items.sorted(by: { $0.order < $1.order })
            self.collectionView.reloadData()
            if (self.activityIndicator?.isAnimating)! {
                self.activityIndicator?.stopAnimating()
            }
            return
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
            
            if self.pager.hasMore {
                self.loadingItems = false
                self.loadItems()
            } else {
                self.items = Array(items!.values)
                let chaptersFromDB = DBManager<Chapter>().getItemsFromDB(filteredBy: String(format: "courseId==%d", self.courseId), byKeyPath: "order")
                DBManager<Chapter>().deleteFromDb(objects: chaptersFromDB)
                DBManager<Chapter>().addData(objects: items!.values)
                if self.items.count == 0 {
                    self.setEmptyText()
                }
                self.items = self.getItemsFromDB()
                self.collectionView.reloadData()
                if (self.activityIndicator?.isAnimating)! {
                    self.activityIndicator?.stopAnimating()
                }
                self.loadingItems = false
            }
        })
    }
    
    func handleError(_ error: TPError) {
        var retryHandler: (() -> Void)?
        if error.kind == .network {
            retryHandler = {
                self.activityIndicator?.startAnimating()
                self.loadItems()
            }
        }
        let (image, title, description) = error.getDisplayInfo()
        if (activityIndicator?.isAnimating)! {
            activityIndicator?.stopAnimating()
        }
        loadingItems = false
        emptyView.setValues(image: image, title: title, description: description,
                            retryHandler: retryHandler)
            
        collectionView.reloadData()
    }
    
    func setEmptyText() {
        emptyView.setValues(image: Images.LearnFlatIcon.image, title: Strings.NO_ITEMS_EXIST,
                            description: Strings.NO_CHAPTER_DESCRIPTION)
    }
    
    @IBAction func back() {
        dismiss(animated: true, completion: nil)
    }
    
}

extension ChaptersViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        if items.count == 0 {
            collectionView.backgroundView?.isHidden = false
        } else {
            collectionView.backgroundView?.isHidden = true
        }
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:
            Constants.CHAPTER_COLLECTION_VIEW_CELL, for: indexPath) as! ChapterCollectionViewCell
        
        cell.initCell(items[indexPath.row], viewController: self)
        return cell
    }
}
