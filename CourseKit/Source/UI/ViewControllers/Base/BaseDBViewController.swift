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

open class BaseDBViewController<T: Mappable>: BaseUIViewController where T:DBModel{
    public var items = [T]()
    
    open override func viewWillAppear(_ animated: Bool) {
        items = getItemsFromDB()
        super.viewWillAppear(animated)
    }
    
    open func getItemsFromDB() -> [T] {
        return DBManager<T>().getItemsFromDB()
    }
    
}
