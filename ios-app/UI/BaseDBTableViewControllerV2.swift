//
//  BaseDBTableViewControllerV2.swift
//  ios-app
//
//  Created by Karthik on 21/05/20.
//  Copyright © 2020 Testpress. All rights reserved.
//

import UIKit
import ObjectMapper
import RealmSwift


class BaseDBTableViewControllerV2<T: TestpressModel, L: TestpressModel>: BasePagedTableViewController<T, L> where L:Object {
    
    var firstCallBack: Bool = true // On firstCallBack load modified items if items already exists

    override func viewWillAppear(_ animated: Bool) {
        items = getItemsFromDb()
        super.viewWillAppear(animated)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if (items.isEmpty || firstCallBack) {
            firstCallBack = false
            tableView.tableFooterView?.isHidden = true
            pager.reset()
            loadItems()
        }
    }
    
    func getItemsFromDb() -> [L] {
        return DBManager<L>().getItemsFromDB()
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
            DBManager<L>().addData(objects: items)
            self.onLoadFinished(items: self.getItemsFromDb())
        })
    }
}
