//
//  BannerAdViewCell.swift
//  ios-app
//
//  Created by Karthik on 30/04/21.
//  Copyright © 2021 Testpress. All rights reserved.
//

import UIKit
import CourseKit

class BannerAdViewCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
    var dashboardData: DashboardResponse?
    
    func initCell(bannerId: Int) {
        let banner = dashboardData?.getBanner(id: bannerId)
        image.kf.setImage(with: URL(string: banner?.image ?? ""))
    }
}
