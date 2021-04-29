//
//  DashboardSection.swift
//  ios-app
//
//  Created by Karthik on 26/04/21.
//  Copyright © 2021 Testpress. All rights reserved.
//

import ObjectMapper
import IGListKit


public class DashboardSection {
    var slug: String?
    var displayName: String?
    var url: String?
    var contentType: String?
    var order: Int?
    var displayType: String?
    var items: [Int]?
    
    public required init?(map: Map) {
        mapping(map: map)
    }
    
    func getIcon() -> UIImage {
        if (slug == "whats_new") {
            return Images.WhatsNewIcon.image
        } else if (slug == "banner_ads") {
            return Images.OffersIcon.image
        } else if (slug == "posts") {
            return Images.RecentPostsIcon.image
        } else if (slug == "leaderboard") {
            return Images.LeaderboardIcon.image
        } else if (slug == "new-courses") {
            return Images.WhatsNewIcon.image
        } else if (slug == "completed") {
            return Images.CompletedIcon.image
        } else if (slug == "resume") {
            return Images.ResumeStudyIcon.image
        }
        
        return Images.WhatsNewIcon.image
    }
}


extension DashboardSection: TestpressModel {
    public func mapping(map: Map) {
        slug <- map["slug"]
        displayName <- map["display_name"]
        url <- map["url"]
        contentType <- map["content_type"]
        order <- map["order"]
        displayType <- map["display_type"]
        items <- map["items"]
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
