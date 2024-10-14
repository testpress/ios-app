//
//  ChapterContentSectionController.swift
//  ios-app
//
//  Created by Karthik on 03/05/21.
//  Copyright © 2021 Testpress. All rights reserved.
//

import IGListKit
import CourseKit

class ChapterContentSectionController: ListSectionController {
    var dashboardData: DashboardResponse?
    var currentSection: DashboardSection?
    var contentId: Int?

    override init() {
        super.init()
        self.inset = UIEdgeInsets(top: 10, left: 10, bottom: 20, right: 10)
    }

    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: 161, height: 155)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: ChapterContentViewCell = collectionContext?.dequeueReusableCell(withNibName: "ChapterContentViewCell", bundle: nil, for: self, at: index) as! ChapterContentViewCell
        cell.dashboardData = dashboardData
        cell.initCell(contentId: contentId!)
        return cell
    }

    override func didUpdate(to object: Any) {
        contentId = object as? Int
    }
    
    override func didSelectItem(at index: Int) {
        let bundle = Bundle(for: TestpressCourse.self)
        let storyboard = UIStoryboard(name: Constants.CHAPTER_CONTENT_STORYBOARD, bundle: bundle)
        let contentDetailViewController = storyboard.instantiateViewController(
            withIdentifier: Constants.CONTENT_DETAIL_PAGE_VIEW_CONTROLLER)
            as! ContentDetailPageViewController
        
        let content = dashboardData?.getContent(id: contentId!)
        contentDetailViewController.contents = [content!
        ]
        contentDetailViewController.title = content?.name
        contentDetailViewController.position = 0
        viewController?.present(contentDetailViewController, animated: true, completion: nil)
    }
}
