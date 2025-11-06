import Foundation
import UIKit

extension String {
    public static func mediumDateShortTime(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }

    public func substring(with nsrange: NSRange) -> Substring? {
        guard let range = Range(nsrange, in: self) else { return nil }
        return self[range]
    }
    
    public var secondsFromString : Int{
        let components = self.components(separatedBy: ":")
            guard components.count == 3 else { return 0 } // Handle invalid format

            let hours = Double(components[0]) ?? 0
            let minutes = Double(components[1]) ?? 0
            let secondsComponents = components[2].components(separatedBy: ".")
            let seconds = Double(secondsComponents[0]) ?? 0
            let totalSeconds = (hours * 3600) + (minutes * 60) + seconds
            return Int(totalSeconds)
    }
}



extension StringProtocol {
    public func nsRanges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [NSRange] {
        var start = startIndex
        let end = endIndex
        var ranges: [NSRange] = []
        while start < end,
            let range = self.range(of: string,
                                   options: options,
                                   range: start..<end,
                                   locale: .current) {
            ranges.append(range.nsRange(in: self))
            start = range.lowerBound < range.upperBound ? range.upperBound :
            index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return ranges
    }
}

