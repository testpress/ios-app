//
//  BaseDBTableViewControllerV2.swift
//  ios-app
//
//  Created by Karthik on 21/05/20.
//  Copyright © 2020 Testpress. All rights reserved.
//

import UIKit
import ObjectMapper

open class BaseDBTableViewControllerV2<T: TestpressModel, L: TestpressModel>: BasePagedTableViewController<T, L> where L:DBModel {
    
    public var firstCallBack: Bool = true // On firstCallBack load modified items if items already exists
    public var networkItems : [L] = []

    open override func viewWillAppear(_ animated: Bool) {
        items = getItemsFromDb().detached()
        super.viewWillAppear(animated)
    }
    
    
    open override func viewDidAppear(_ animated: Bool) {
        if (items.isEmpty || firstCallBack) {
            firstCallBack = false
            tableView.tableFooterView?.isHidden = true
            pager.reset()
            loadItems()
        }
    }
    
    open func getItemsFromDb() -> [L] {
        return DBManager<L>().getItemsFromDB()
    }
    
    
    open override func loadItems() {
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
            self.networkItems.append(contentsOf: items!.values)
            
            if self.pager.hasMore {
                self.loadingItems = false
                self.loadItems()
            } else {
                self.deleteExistingItemsFromDB()
                DBManager<L>().addData(objects: self.networkItems)
                self.onLoadFinished(items: self.getItemsFromDb())
            }
        })
    }
    
    open func deleteExistingItemsFromDB() {
        DBManager<L>().deleteFromDb(objects: getItemsFromDb())
    }
}
