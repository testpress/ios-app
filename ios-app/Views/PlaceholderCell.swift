//
//  ContentCarouselCell.swift
//  ios-app
//
//  Created by Karthik on 26/04/21.
//  Copyright © 2021 Testpress. All rights reserved.
//

import UIKit

class PlaceholderCell: UICollectionViewCell {
    lazy private var label: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textAlignment = .center
        view.textColor = .white
        view.font = .boldSystemFont(ofSize: 18)
        self.contentView.addSubview(view)
        return view
    }()

    var text: String? {
        get {
            return label.text
        }
        set {
            label.text = newValue
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = contentView.bounds
    }
}
