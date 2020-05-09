//
//  BaseDBViewController.swift
//  ios-app
//
//  Created by Karthik on 07/05/20.
//  Copyright © 2020 Testpress. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper
import RealmSwift


class BaseDBViewController<T: Mappable>: UIViewController where T:Object{
    var items = [T]()
    
    override func viewWillAppear(_ animated: Bool) {
        items = getItemsFromDB()
        super.viewWillAppear(animated)
    }
    
    func getItemsFromDB() -> [T] {
        return DBManager<T>().getItemsFromDB()
    }
    
}
