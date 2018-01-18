//
//  BaseDBViewController.swift
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
import ObjectMapper
import RealmSwift

class BaseDBViewController<T: Mappable>: TPBasePagedTableViewController<T> where T:Object {
    
    override func viewWillAppear(_ animated: Bool) {
        items = getItemsFromDb()
        super.viewWillAppear(animated)
    }
    
    func getItemsFromDb() -> [T] {
        return DBManager<T>().getItemsFromDB()
    }
    
    override func loadItems() {
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
            
            let items = Array(items!.values)
            DBManager<T>().addData(objects: items)
            self.items = self.getItemsFromDb()
            if self.items.count == 0 {
                self.setEmptyText()
            }
            self.delegate?.onItemsLoaded()
            self.tableView.reloadData()
            if self.activityIndicator.isAnimating {
                self.activityIndicator.stopAnimating()
            }
            self.tableView.tableFooterView?.isHidden = true
            self.loadingItems = false
        })
    }
    
}
