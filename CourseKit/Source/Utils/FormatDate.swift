//
//  FormatDate.swift
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

import Foundation

public class FormatDate {
    
    public static func getDate(from dateString: String,
                        givenFormat: String? = nil) -> Date? {
        
        let dateFormatter = DateFormatter()
        var givenFormat = givenFormat
        if givenFormat == nil {
            if dateString.contains(".") {
                givenFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
            } else {
                givenFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            }
        }
        dateFormatter.dateFormat = givenFormat
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        guard let date = dateFormatter.date(from: dateString) else {
            debugPrint("no date from string")
            return nil
        }
        return date
    }
    
    public static func format(date: Date, requiredFormat: String? = nil) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        var requiredFormat = requiredFormat
        if requiredFormat == nil {
            requiredFormat = "dd MMM"
            dateFormatter.dateFormat = requiredFormat!
            let newDateString = dateFormatter.string(from: date)
            requiredFormat = "yy"
            dateFormatter.dateFormat = requiredFormat!
            return newDateString + " '" + dateFormatter.string(from: date)
        }
        dateFormatter.dateFormat = requiredFormat!
        return dateFormatter.string(from: date)
    }
    
    public static func format(dateString: String?,
                       givenFormat: String? = nil,
                       requiredFormat: String? = nil) -> String {
        
        if dateString == nil {
            return "forever"
        }
        guard let date = getDate(from: dateString!, givenFormat: givenFormat) else {
            return ""
        }
        return format(date: date, requiredFormat: requiredFormat)
    }
    
    public static func compareDate(dateString1: String,
                            dateString2: String,
                            givenFormat: String? = nil) -> Bool {
        
        let date1 = getDate(from: dateString1, givenFormat: givenFormat)!
        let date2 = getDate(from: dateString2, givenFormat: givenFormat)!
        return date1 > date2
    }
    
    public static func getElapsedTime(dateString: String, givenFormat: String? = nil) -> String {
        guard let date = getDate(from: dateString, givenFormat: givenFormat) else {
            return ""
        }
        return getElapsedTime(date: date)
    }
    
    public static func getElapsedTime(date: Date) -> String {
        // https://stackoverflow.com/a/27337951/5134215
        var weeksFromNow: Int {
            return Calendar.current.dateComponents([.weekOfYear], from: date, to: Date())
                .weekOfYear ?? 0
        }
        var daysFromNow: Int {
            return Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
        }
        var hoursFromNow: Int {
            return Calendar.current.dateComponents([.hour], from: date, to: Date()).hour ?? 0
        }
        var minutesFromNow: Int {
            return Calendar.current.dateComponents([.minute], from: date, to: Date()).minute ?? 0
        }
        var secondsFromNow: Int {
            return Calendar.current.dateComponents([.second], from: date, to: Date()).second ?? 0
        }
        if weeksFromNow > 0 {
            return format(date: date)
        }
        if daysFromNow > 0 {
            return daysFromNow == 1 ? "Yesterday" : "\(daysFromNow)d ago"
        }
        if hoursFromNow > 0 {
            return "\(hoursFromNow)h ago"
        }
        if minutesFromNow > 0 {
            return "\(minutesFromNow)m ago"
        }
        return "Just now"
    }
    
    public static func utcToLocalTime(dateStr: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "H:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if let date = dateFormatter.date(from: dateStr) {
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = "h:mm a"
        
            return dateFormatter.string(from: date)
        }
        return nil
    }
}
