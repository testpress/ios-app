//
//  VideoPlayerUtils.swift
//  ios-app
//
//  Created by Karthik raja on 12/6/19.
//  Copyright © 2019 Testpress. All rights reserved.
//

import Foundation


enum PlaybackSpeed:String {
    case verySlow = "0.5x"
    case slow = "0.75x"
    case normal = "Normal"
    case fast = "1.25x"
    case veryFast = "1.5x"
    case double = "2x"
    
    var value: Float {
        switch self {
        case .verySlow:
            return 0.5
        case .slow:
            return 0.75
        case .normal:
            return 1.00
        case .fast:
            return 1.25
        case .veryFast:
            return 1.5
        case .double:
            return 2.00
        }
    }
    
    var label: String {
        switch self {
        case .normal:
            return "1x"
        default:
            return self.rawValue
        }
    }
}

extension PlaybackSpeed: CaseIterable {}


enum PlayerStatus {
    case readyToPlay
    case playing
    case paused
    case finished
}


enum VideoDurationType {
    case remainingTime
    case totalTime
    
    func getDurationString (seconds : Double) -> String {
        if seconds.isNaN || seconds.isInfinite {
            return "00:00"
        }
        
        let intSeconds = Int(seconds)
        let minute = intSeconds / 60 % 60
        let second = intSeconds % 60
        return String(format: "%02i:%02i", minute, second)
    }
    
    func value(seconds:Double, total:Double) -> String {
        switch self {
        case .remainingTime:
            return "-\(getDurationString(seconds: total-seconds))"
        case .totalTime:
            return getDurationString(seconds: total)
        }
    }
}
