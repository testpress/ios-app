//
//  LeaderboardItemViewCell.swift
//  ios-app
//
//  Created by Karthik on 29/04/21.
//  Copyright © 2021 Testpress. All rights reserved.
//

import UIKit

class LeaderboardItemViewCell: UICollectionViewCell {
    @IBOutlet weak var rank: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var trophyCount: UILabel!
    var dashboardData: DashboardResponse?

    func initCell(leaderboardItemId: Int, index: Int) {
        let leaderboardItem = dashboardData?.getLeaderboardItem(id: leaderboardItemId)
        rank.text = String(index + 1)
        trophyCount.text = leaderboardItem?.trophiesCount
        name.text = leaderboardItem?.user?.displayName
        profileImage.kf.setImage(with: URL(string: leaderboardItem?.user?.mediumImage ?? ""), placeholder: Images.PlaceHolder.image)
    }
}
