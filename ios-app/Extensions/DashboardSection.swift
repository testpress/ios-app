//
//  DashboardSection.swift
//  ios-app
//
//  Created by Testpress on 04/10/24.
//  Copyright © 2024 Testpress. All rights reserved.
//

import Foundation
import CourseKit
import UIKit
import IGListKit

extension DashboardSection{
    public func getIcon() -> UIImage {
        switch slug {
        case "posts":
            return Images.RecentPostsIcon.image
        case "banner_ads":
            return Images.OffersIcon.image
        case "whats_new":
            return Images.WhatsNewIcon.image
        case "leaderboard":
            return Images.LeaderboardIcon.image
        case "completed":
            return Images.CompletedIcon.image
        case "resume":
            return Images.ResumeStudyIcon.image
        default:
            return Images.LeaderboardIcon.image
        }
    }
}

extension DashboardSection: ListDiffable {
    public func diffIdentifier() -> NSObjectProtocol {
        return items! as NSObjectProtocol
    }
    
    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard self !== object else { return true }
        guard let object = object as? DashboardSection else { return false }
        return items! == object.items
    }
}
