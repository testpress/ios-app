//
//  LeaderboardSectionController.swift
//  ios-app
//
//  Created by Karthik on 29/04/21.
//  Copyright © 2021 Testpress. All rights reserved.
//

import IGListKit


final class LeaderboardSectionController: BaseSectionController {
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 50)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: LeaderboardItemViewCell = collectionContext?.dequeueReusableCell(withNibName: "LeaderboardItemViewCell", bundle: nil, for: self, at: index) as! LeaderboardItemViewCell
        cell.dashboardData = dashboardData
        cell.initCell(leaderboardItemId: currentSection!.items![index], index: index)
        return cell
    }
}
