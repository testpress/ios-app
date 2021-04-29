//
//  ContentsSectionController.swift
//  ios-app
//
//  Created by Karthik on 26/04/21.
//  Copyright © 2021 Testpress. All rights reserved.
//

import IGListKit


class PlaceHolderSectionController: ListSectionController {
    private var number: Int?

    override init() {
        super.init()
        self.inset = UIEdgeInsets(top: 20, left: 0, bottom: 50, right: 20)
    }

    override func sizeForItem(at index: Int) -> CGSize {
        let height = collectionContext?.containerSize.height ?? 0
        return CGSize(width: height, height: height)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: PlaceholderCell = collectionContext?.dequeueReusableCell(of: PlaceholderCell.self, for: self, at: index) as! PlaceholderCell
        let value = number ?? 0
        cell.text = "\(value + 1)"
        cell.backgroundColor = UIColor(red: 237 / 255.0, green: 73 / 255.0, blue: 86 / 255.0, alpha: 1)
        return cell
    }

    override func didUpdate(to object: Any) {
        number = object as? Int
    }
}
