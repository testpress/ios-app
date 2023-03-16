//
//  ContentAttemptSectionController.swift
//  ios-app
//
//  Created by Karthik on 03/05/21.
//  Copyright © 2021 Testpress. All rights reserved.
//

import IGListKit

class ContentAttemptSectionController: ChapterContentSectionController {
    var contentAttemptId: Int?

    override func didUpdate(to object: Any) {
        contentAttemptId = object as? Int
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: ChapterContentViewCell = collectionContext?.dequeueReusableCell(withNibName: "ChapterContentViewCell", bundle: nil, for: self, at: index) as! ChapterContentViewCell
        cell.dashboardData = dashboardData
        let contentAttempt = dashboardData?.getChapterContentAttempt(id: contentAttemptId!)
        contentId = (contentAttempt?.chapterContentId)!
        cell.initCell(contentId: contentId!, contentAttemptId: contentAttemptId, showVideoProgress: currentSection?.slug == "resume")
        return cell
    }
}

