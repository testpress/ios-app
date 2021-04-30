//
//  BannerSectionController.swift
//  ios-app
//
//  Created by Karthik on 30/04/21.
//  Copyright © 2021 Testpress. All rights reserved.
//

import IGListKit


class BannerSectionController: ListSectionController {
    var dashboardData: DashboardResponse?
    var currentSection: DashboardSection?
    var contentId: Int?
    
    override init() {
        super.init()
        self.inset = UIEdgeInsets(top: 20, left: 10, bottom: 50, right: 10)
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        var width = (collectionContext?.containerSize.width ?? 0) * (3/4)

        if (UIDevice.current.userInterfaceIdiom == .pad) {
            width = 306
        }
        return CGSize(width: width, height: 180)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: BannerAdViewCell = collectionContext?.dequeueReusableCell(withNibName: "BannerAdViewCell", bundle: nil, for: self, at: index) as! BannerAdViewCell
        cell.dashboardData = dashboardData
        cell.initCell(bannerId: contentId!)
        return cell
    }
    
    override func didUpdate(to object: Any) {
        contentId = object as? Int
    }
}
