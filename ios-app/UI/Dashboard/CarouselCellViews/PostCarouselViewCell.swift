//
//  PostCarouselViewCell.swift
//  ios-app
//
//  Created by Karthik on 30/04/21.
//  Copyright © 2021 Testpress. All rights reserved.
//

import UIKit


class PostCarouselViewCell: UICollectionViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var image: UIImageView!
    var dashboardData: DashboardResponse?

    func initCell(postId: Int) {
        let post = dashboardData?.getPost(id: postId)
        title.text = post?.title
        image.kf.setImage(with: URL(string: post?.coverImageMedium ?? ""))
    }
}

