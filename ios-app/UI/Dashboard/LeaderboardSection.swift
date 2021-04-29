//
//  LeaderboardSection.swift
//  ios-app
//
//  Created by Karthik on 28/04/21.
//  Copyright © 2021 Testpress. All rights reserved.
//


import IGListKit


class LeaderboardSection: ListSectionController {
    var dashboardData: DashboardResponse?
    var currentSection: DashboardSection?
    var contentId: Int?

    override init() {
        super.init()
        self.inset = UIEdgeInsets(top: 20, left: 10, bottom: 50, right: 10)
    }

    override func sizeForItem(at index: Int) -> CGSize {
        let height = collectionContext?.containerSize.height ?? 0
        let width = collectionContext?.containerSize.width ?? 0
        return CGSize(width: width, height: 80)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: LeaderboardItemViewCell = collectionContext?.dequeueReusableCell(withNibName: "LeaderboardItemViewCell", bundle: nil, for: self, at: index) as! LeaderboardItemViewCell
        cell.dashboardData = dashboardData
//        cell.initCell(postId: contentId!)
        return cell
    }

    override func didUpdate(to object: Any) {
        contentId = object as? Int
    }
}
