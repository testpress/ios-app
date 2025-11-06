//
//  VideoPlayerUtils.swift
//  ios-app
//
//  Created by Karthik raja on 12/6/19.
//  Copyright © 2019 Testpress. All rights reserved.
//

import Foundation


public enum PlaybackSpeed:String {
    case verySlow = "0.5x"
    case slow = "0.75x"
    case normal = "Normal"
    case fast = "1.25x"
    case veryFast = "1.5x"
    case double = "2x"
    
    public var value: Float {
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
    
    public var label: String {
        switch self {
        case .normal:
            return "1x"
        default:
            return self.rawValue
        }
    }
}

extension PlaybackSpeed: CaseIterable {}


public enum PlayerStatus {
    case readyToPlay
    case playing
    case paused
    case finished
}


public enum VideoDurationType {
    case remainingTime
    case totalTime
    
    public func getDurationString (seconds : Double) -> String {
        if seconds.isNaN || seconds.isInfinite {
            return "00:00"
        }
        let hour = Int(seconds) / 3600
        let minute = Int(seconds) / 60 % 60
        let second = Int(seconds) % 60
        let time = hour > 0 ? String(format: "%02i:%02i:%02i", hour, minute, second) :String(format: "%02i:%02i", minute, second)
        return time
    }
    
    public func value(seconds:Double, total:Double) -> String {
        switch self {
        case .remainingTime:
            return "-\(getDurationString(seconds: total-seconds))"
        case .totalTime:
            return getDurationString(seconds: total)
        }
    }
}

public struct VideoQuality {
    public var resolution: String
    public var bitrate: Int
    
    public init(resolution: String, bitrate: Int) {
        self.resolution = resolution
        self.bitrate = bitrate
    }
}
