import Foundation
import UIKit

extension String {
    static func mediumDateShortTime(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }

    func substring(with nsrange: NSRange) -> Substring? {
        guard let range = Range(nsrange, in: self) else { return nil }
        return self[range]
    }
    
    var secondsFromString : Int{
        var n = 3600
        return self.components(separatedBy: ":").reduce(0) {
            defer { n /= 60 }
            return $0 + (Int($1) ?? 0) * n
        }
    }
}



extension StringProtocol {
    func nsRanges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [NSRange] {
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

