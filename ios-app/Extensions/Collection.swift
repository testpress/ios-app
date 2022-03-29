//
//  Collection.swift
//  ios-app
//
//  Created by Karthik on 26/05/20.
//  Copyright © 2020 Testpress. All rights reserved.
//

import Foundation

extension Optional where Wrapped: Collection {
    var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }    
}

extension Collection {
    public var isNotEmpty: Bool {
        return !self.isEmpty
    }
}
