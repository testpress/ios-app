//
//  TimeUtils.swift
//  ios-app

import Foundation


public class TimeUtils {
    static func convertDurationStringToSeconds(durationString: String) -> Int {
        var durationList = durationString.split(separator: ":")
        var seconds = 0
        var minutes = 1
        
        while (durationList.count > 0) {
            seconds += minutes * Int(durationList.popLast()!)!
            minutes *= 60
        }
        
        return seconds
    }
}

