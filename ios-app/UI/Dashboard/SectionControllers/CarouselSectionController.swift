//
//  CarouselSectionController.swift
//  ios-app
//
//  Created by Karthik on 30/04/21.
//  Copyright © 2021 Testpress. All rights reserved.
//

import IGListKit
import CourseKit

class CarouselSectionController: BaseSectionController {
    var sections: [DashboardSection] = []

    lazy var adapter: ListAdapter = {
        let adapter = ListAdapter(updater: ListAdapterUpdater(),
                                  viewController: self.viewController)
        adapter.dataSource = self
        return adapter
    }()
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: HorizontalSectionCell = collectionContext?.dequeueReusableCell(of:  HorizontalSectionCell.self, for: self, at: index) as! HorizontalSectionCell
        adapter.collectionView = cell.collectionView
        return cell
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        if (currentSection?.contentType == "chapter_content") {
            return CGSize(width: collectionContext!.containerSize.width, height: 155)
        }
        return CGSize(width: collectionContext!.containerSize.width, height: 200)
    }
}


extension CarouselSectionController: ListAdapterDataSource {
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return (currentSection?.items ?? []) as [ListDiffable]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        
        if (currentSection?.contentType == "post") {
            let sectionController = PostSectionController()
            sectionController.dashboardData = dashboardData
            sectionController.currentSection = currentSection
            return sectionController
        } else if (currentSection?.contentType == "chapter_content") {
            let sectionController = ChapterContentSectionController()
            sectionController.dashboardData = dashboardData
            sectionController.currentSection = currentSection
            return sectionController
        } else if (currentSection?.contentType == "chapter_content_attempt") {
            let sectionController = ContentAttemptSectionController()
            sectionController.dashboardData = dashboardData
            sectionController.currentSection = currentSection
            return sectionController
        }

        let sectionController = BannerSectionController()
        sectionController.dashboardData = dashboardData
        sectionController.currentSection = currentSection
        return sectionController
    }
}
