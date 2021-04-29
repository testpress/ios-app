//
//  DashboardSectionsController.swift
//  ios-app
//
//  Created by Karthik on 26/04/21.
//  Copyright © 2021 Testpress. All rights reserved.
//

import IGListKit

class DashboardSectionsController: ListSectionController, ListSupplementaryViewSource {
    var sections: [DashboardSection] = []
    var currentSection: DashboardSection?
    var dashboardData: DashboardResponse?
    
    lazy var adapter: ListAdapter = {
        let adapter = ListAdapter(updater: ListAdapterUpdater(),
                                  viewController: self.viewController)
        adapter.dataSource = self
        return adapter
    }()
    
    override init() {
        super.init()
        self.inset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        supplementaryViewSource = self
    }

    override func sizeForItem(at index: Int) -> CGSize {
        if (currentSection?.contentType == "banner_ad") {
            return CGSize(width: collectionContext!.containerSize.width, height: 220)
        } else if (currentSection?.contentType == "post") {
            return CGSize(width: collectionContext!.containerSize.width, height: 180)
        } else if (currentSection?.contentType == "trophy_leaderboard") {
            return CGSize(width: collectionContext!.containerSize.width, height: 200)
        }
        return CGSize(width: collectionContext!.containerSize.width, height: 150)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: EmbeddedCollectionViewCell = collectionContext?.dequeueReusableCell(of:  EmbeddedCollectionViewCell.self, for: self, at: index) as! EmbeddedCollectionViewCell
        adapter.collectionView = cell.collectionView
        return cell
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
    func supportedElementKinds() -> [String] {
        return [UICollectionView.elementKindSectionHeader, UICollectionView.elementKindSectionFooter]
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
        view.setTitle(titleText: currentSection?.displayName ?? "", icon: currentSection?.getIcon() ?? Images.WhatsNewIcon.image)
        return view
    }
}

extension DashboardSectionsController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return (currentSection?.items ?? []) as [ListDiffable]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if (currentSection?.contentType == "chapter_content") {
            let sectionController = ContentsCarouselSectionController()
            sectionController.dashboardData = dashboardData
            sectionController.currentSection = currentSection
            return sectionController
        } else if (currentSection?.contentType == "banner_ad") {
            let sectionController1 = BannerSectionController()
            sectionController1.dashboardData = dashboardData
            sectionController1.currentSection = currentSection
            return sectionController1
        } else if (currentSection?.contentType == "post") {
            let sectionController1 = PostSectionController()
            sectionController1.dashboardData = dashboardData
            sectionController1.currentSection = currentSection
            return sectionController1
        } else if (currentSection?.contentType == "trophy_leaderboard") {
            let sectionController = LeaderboardSection()
            sectionController.dashboardData = dashboardData
            sectionController.currentSection = currentSection
            return sectionController
        } else if (currentSection?.contentType == "chapter_content_attempt") {
            let sectionController = ContentAttemptSectionController()
            sectionController.dashboardData = dashboardData
            sectionController.currentSection = currentSection
            return sectionController
        }
        return PlaceHolderSectionController()
    }
}
