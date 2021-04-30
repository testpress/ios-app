//
//  BaseSectionController.swift
//  ios-app
//
//  Created by Karthik on 29/04/21.
//  Copyright © 2021 Testpress. All rights reserved.
//

import IGListKit


class BaseSectionController: ListSectionController, ListSupplementaryViewSource {    
    var currentSection: DashboardSection?
    var dashboardData: DashboardResponse?
    
    
    override func numberOfItems() -> Int {
        return currentSection?.items?.count ?? 0
    }
    
    override init() {
        super.init()
        supplementaryViewSource = self
    }
    
    
    func supportedElementKinds() -> [String] {
        return [UICollectionView.elementKindSectionHeader]
    }
    
    func sizeForSupplementaryView(ofKind elementKind: String, at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 40)
    }
    
    func viewForSupplementaryElement(ofKind elementKind: String, at index: Int) -> UICollectionReusableView {
        switch elementKind {
            case UICollectionView.elementKindSectionHeader:
                return userHeaderView(atIndex: index)
            default:
                fatalError()
        }
    }
    
    
    private func userHeaderView(atIndex index: Int) -> UICollectionReusableView {
        let view: DashboardSectionHeaderCell = collectionContext!.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            for: self,
            nibName: "DashboardSectionHeaderCell",
            bundle: nil,
            at: index) as! DashboardSectionHeaderCell
        view.setTitle(titleText: currentSection?.displayName ?? "", icon: currentSection?.getIcon() ?? Images.LeaderboardIcon.image)
        return view
    }
}
