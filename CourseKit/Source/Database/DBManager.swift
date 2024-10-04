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

public class DBConnection {
    
    static let sharedConnection = DBConnection()
    
    private var database: Realm
    
    private init() {
        database = try! Realm()
    }
    
    public static func configure(){
        let config = Realm.Configuration(schemaVersion: 43)
        Realm.Configuration.defaultConfiguration = config
    }
    
    public func getDB() -> Realm {
        return database
    }
    
    static public func clearAllTables() {
        try! sharedConnection.database.write {
            sharedConnection.database.deleteAll()
        }
    }
    
    static public func clearTables() {
        // TODO: Clear all tables except institute settings through loop
        /*
         This method is used to clear user related tables.
         The objective of this method is to not clear InstituteSettings tables
         as it is neccessary for login screen after logout.
        */
        let course = sharedConnection.database.objects(Course.self)
        try! sharedConnection.database.write {
            sharedConnection.database.delete(course)
        }
    }
    
}

public class DBManager<T: Object> {
    
    private var database: Realm
    
    public init() {
        database = DBConnection.sharedConnection.getDB()
    }
    
    public func getResultsFromDB() -> Results<T> {
        return database.objects(T.self)
    }
    
    public func isEmpty() -> Bool {
        return database.objects(T.self).isEmpty
    }
    
    public func getItemsFromDB() -> [T] {
        return Array(getResultsFromDB())
    }
    
    public func getItemsFromDB(filteredBy: String, byKeyPath: String, ascending: Bool = true) -> [T] {
        return Array(getResultsFromDB()
            .filter(filteredBy)
            .sorted(byKeyPath: byKeyPath, ascending: ascending))
    }
    
    public func getSortedItemsFromDB(byKeyPath: String, ascending: Bool = true) -> [T] {
        return Array(getResultsFromDB().sorted(byKeyPath: byKeyPath, ascending: ascending))
    }
    
    public func addData(object: T) {
        try! database.write {
            database.add(object, update: .modified)
        }
    }
    
    public func addData(objects: [T]) {
        try! database.write {
            database.add(objects, update: .modified)
        }
    }
    
    public func deleteAllFromDatabase() {
        try! database.write {
            database.delete(getResultsFromDB())
        }
    }
    
    public func deleteFromDb(objects: [T]) {
        try! database.write {
            database.delete(objects)
        }
    }
    
    public func deleteFromDb(object: T) {
        try! database.write {
            database.delete(object)
        }
    }
    
    
    public func write(_ transaction: () -> Void) {
        do {
            try database.write {
                transaction()
            }
        } catch {
            print("Error during Realm write transaction: \(error)")
        }
    }
}
