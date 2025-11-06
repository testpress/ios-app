//
//  StringExtension.swift
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

import UIKit

extension String {
    
    public var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            let htmlType = NSAttributedString.DocumentType.html
            return try NSAttributedString(
                data: data,
                options: [NSAttributedString.DocumentReadingOptionKey.documentType: htmlType],
                documentAttributes: nil
            )
        } catch {
            return NSAttributedString()
        }
    }
    
    public var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    
    public func trim() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public static func getValue(_ anyValue: Any) -> String {
        if let intValue = anyValue as? Int {
            return String(intValue)
        } else if let stringValue = anyValue as? String {
            return stringValue
        }
        return "NA"
    }
}
