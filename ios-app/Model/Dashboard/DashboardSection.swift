//
//  DashboardSection.swift
//  ios-app
//
//  Created by Karthik on 29/04/21.
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
        return Images.LeaderboardIcon.image
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
