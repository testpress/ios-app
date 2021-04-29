//
//  PostSectionController.swift
//  ios-app
//
//  Created by Karthik on 28/04/21.
//  Copyright © 2021 Testpress. All rights reserved.
//


import IGListKit


class PostSectionController: ListSectionController {
    var dashboardData: DashboardResponse?
    var currentSection: DashboardSection?
    var contentId: Int?

    override init() {
        super.init()
        self.inset = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
    }

    override func sizeForItem(at index: Int) -> CGSize {
        let height = collectionContext?.containerSize.height ?? 0
        let width = collectionContext?.containerSize.width ?? 0
        return CGSize(width: width * (0.55), height: 170)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: PostCarouselViewCell = collectionContext?.dequeueReusableCell(withNibName: "PostCarouselViewCell", bundle: nil, for: self, at: index) as! PostCarouselViewCell
        cell.dashboardData = dashboardData
        cell.initCell(postId: contentId!)
        return cell
    }

    override func didSelectItem(at index: Int) {
        let storyboard = UIStoryboard(name: Constants.POST_STORYBOARD, bundle: nil)
        
        let viewController1 = storyboard.instantiateViewController(withIdentifier:
                Constants.POST_DETAIL_VIEW_CONTROLLER) as! PostDetailViewController
        
        viewController1.url = dashboardData?.getPost(id: contentId!)?.url
        viewController?.present(viewController1, animated: true, completion: nil)
    }
    
    override func didUpdate(to object: Any) {
        contentId = object as? Int
    }
}
