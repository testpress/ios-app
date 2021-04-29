//
//  Repository.swift
//  ios-app
//
//  Created by Karthik on 26/04/21.
//  Copyright © 2021 Testpress. All rights reserved.
//

import Foundation

protocol Repository {
    associatedtype ResultType
    
    func getAll() -> [ResultType]
    func get(id: Int) -> ResultType?
    func create(obj: ResultType) -> ResultType
    func update(obj: ResultType) -> ResultType
    func delete(obj: ResultType) -> ResultType
}
