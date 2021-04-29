//
//  ContentsCarouselSectionController.swift
//  ios-app
//
//  Created by Karthik on 26/04/21.
//  Copyright © 2021 T  estpress. All rights reserved.
//

import IGListKit

class ContentsCarouselSectionController: ListSectionController {
    var dashboardData: DashboardResponse?
    var currentSection: DashboardSection?
    var contentId: Int?

    override init() {
        super.init()
        self.inset = UIEdgeInsets(top: 10, left: 10, bottom: 20, right: 10)
    }

    override func sizeForItem(at index: Int) -> CGSize {
        let height = collectionContext?.containerSize.height ?? 0
        return CGSize(width: height, height: 140)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: ContentsCarouselViewCell = collectionContext?.dequeueReusableCell(withNibName: "ContentsCarouselViewCell", bundle: nil, for: self, at: index) as! ContentsCarouselViewCell
        cell.dashboardData = dashboardData
        cell.initCell(contentId: contentId!)
        return cell
    }

    override func didUpdate(to object: Any) {
        contentId = object as? Int
    }
    
    override func didSelectItem(at index: Int) {
        let storyboard = UIStoryboard(name: Constants.CHAPTER_CONTENT_STORYBOARD, bundle: nil)
        let viewController1 = storyboard.instantiateViewController(
            withIdentifier: Constants.CONTENT_DETAIL_PAGE_VIEW_CONTROLLER)
            as! ContentDetailPageViewController
        
        let content = dashboardData?.getContent(id: contentId!)
        viewController1.contents = [content!
        ]
        viewController1.title = content?.name
        viewController1.position = 0
        viewController?.present(viewController1, animated: true, completion: nil)
    }
}
