//
//  DBManager.swift
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

import ObjectMapper
import RealmSwift

class DBInstance {
    
    static let sharedInstance = DBInstance()
    
    private var database: Realm
    
    private init() {
        database = try! Realm()
    }
    
    func getDB() -> Realm {
        return database
    }
    
    static func clearAllTables() {
        try! sharedInstance.database.write {
            sharedInstance.database.deleteAll()
        }
    }
    
}

class DBManager<T: Object> {
    
    private var database: Realm
    
    public init() {
        database = DBInstance.sharedInstance.getDB()
    }
    
    func getResultsFromDB() -> Results<T> {
        return database.objects(T.self)
    }
    
    func getItemsFromDB() -> [T] {
        return Array(getResultsFromDB())
    }
    
    func getItemsFromDB(filteredBy: String, byKeyPath: String, ascending: Bool = true) -> [T] {
        return Array(getResultsFromDB()
            .filter(filteredBy)
            .sorted(byKeyPath: byKeyPath, ascending: ascending))
    }
    
    func getSortedItemsFromDB(byKeyPath: String, ascending: Bool = true) -> [T] {
        return Array(getResultsFromDB().sorted(byKeyPath: byKeyPath, ascending: ascending))
    }
    
    func addData(object: T) {
        try! database.write {
            database.add(object, update: true)
        }
    }
    
    func addData(objects: [T]) {
        try! database.write {
            database.add(objects, update: true)
        }
    }
    
    func deleteAllFromDatabase() {
        try! database.write {
            database.delete(getResultsFromDB())
        }
    }
    
    func deleteFromDb(object: T) {
        try! database.write {
            database.delete(object)
        }
    }
}