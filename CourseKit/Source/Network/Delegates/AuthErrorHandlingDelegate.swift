//
//  AuthErrorHandlingDelegate.swift
//  ios-app
//
//  Created by Testpress on 07/10/24.
//  Copyright © 2024 Testpress. All rights reserved.
//

import Foundation

public protocol AuthErrorHandlingDelegate {
    func handleUnauthenticatedError()
    func handleMaxLoginLimitError()
    func handleMultipleLoginRestrictionError(error: TPError)
}
