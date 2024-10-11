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

public class BaseDBViewController<T: Mappable>: UIViewController where T:DBModel{
    public var items = [T]()
    
    public override func viewWillAppear(_ animated: Bool) {
        items = getItemsFromDB()
        super.viewWillAppear(animated)
    }
    
    public func getItemsFromDB() -> [T] {
        return DBManager<T>().getItemsFromDB()
    }
    
}
