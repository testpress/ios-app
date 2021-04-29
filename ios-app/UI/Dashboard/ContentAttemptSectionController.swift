//
//  ContentAttemptSectionController.swift
//  ios-app
//
//  Created by Karthik on 29/04/21.
//  Copyright © 2021 Testpress. All rights reserved.
//

import IGListKit

class ContentAttemptSectionController: ContentsCarouselSectionController {
    var contentAttemptId: Int?

    override func didUpdate(to object: Any) {
        contentAttemptId = object as? Int
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: ContentsCarouselViewCell = collectionContext?.dequeueReusableCell(withNibName: "ContentsCarouselViewCell", bundle: nil, for: self, at: index) as! ContentsCarouselViewCell
        cell.dashboardData = dashboardData
        let contentAttempt = dashboardData?.getChapterContentAttempt(id: contentAttemptId!)
        contentId = (contentAttempt?.chapterContentId)!
        cell.initCell(contentId: contentId!, contentAttemptId: contentAttemptId, showVideoProgress: currentSection?.slug == "resume")
        return cell
    }
}
