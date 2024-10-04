//
//  PostSectionController.swift
//  ios-app
//
//  Created by Karthik on 30/04/21.
//  Copyright © 2021 Testpress. All rights reserved.
//

import IGListKit
import CourseKit


class PostSectionController: ListSectionController {
    var dashboardData: DashboardResponse?
    var currentSection: DashboardSection?
    var contentId: Int?

    override init() {
        super.init()
        self.inset = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
    }

    override func sizeForItem(at index: Int) -> CGSize {
        var width = (collectionContext?.containerSize.width ?? 0) * (0.55)
        var height = 170.0
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            width = 306
            height = 192
        }
        return CGSize(width: Double(width), height: height)
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
