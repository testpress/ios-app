//
//  DashboardSectionHeaderCell.swift
//  ios-app
//
//  Created by Karthik on 29/04/21.
//  Copyright © 2021 Testpress. All rights reserved.
//

import UIKit

class DashboardSectionHeaderCell: UICollectionViewCell {
    @IBOutlet weak var title: UILabel!
    
    func setTitle(titleText: String, icon: UIImage) {
        title.addLeading(image: icon, text: titleText)
    }

}
