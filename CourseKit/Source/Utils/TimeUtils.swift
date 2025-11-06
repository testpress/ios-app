//
//  TimeUtils.swift
//  ios-app

import Foundation


public class TimeUtils {
    public static func convertDurationStringToSeconds(durationString: String) -> Int {
        var durationList = durationString.split(separator: ":")
        var seconds = 0
        var minutes = 1
        
        while (durationList.count > 0) {
            seconds += minutes * Int(durationList.popLast()!)!
            minutes *= 60
        }
        
        return seconds
    }
    
    public static func addTimeStrings(_ timeTaken: String?,_ remainingTime: String?) -> String {
        // Here, we add one second to totalTime because remainingTime is always one second less than the actual value.
        let totalTime = (timeTaken?.secondsFromString ?? 0) + (remainingTime?.secondsFromString ?? 0) + 1
        let hours = (totalTime / (60 * 60)) % 12
        let minutes = (totalTime / 60) % 60
        let seconds = totalTime % 60
        return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    }
    
    public static func formatDuration(seconds: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 2

        if let formattedString = formatter.string(from: seconds) {
            return formattedString
        } else {
            return "0s"
        }
    }
    
    public static func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        let formattedString = dateFormatter.string(from: date)
        return formattedString
    }
}

