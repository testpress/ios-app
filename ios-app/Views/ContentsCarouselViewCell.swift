//
//  ContentsCarouselViewCell.swift
//  ios-app
//
//  Created by Karthik on 27/04/21.
//  Copyright © 2021 Testpress. All rights reserved.
//

import UIKit

class ContentsCarouselViewCell: UICollectionViewCell {
    @IBOutlet weak var contentTitle: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var chapterTitle: UILabel!
    @IBOutlet weak var contentTypeIcon: UIImageView!
    @IBOutlet weak var videoWatchProgress: UIProgressView!
    @IBOutlet weak var playIcon: UIImageView!
    @IBOutlet weak var infoTitle: PillUILabel!
    @IBOutlet weak var infoLayout: UIStackView!
    @IBOutlet weak var infoSubtitle: UILabel!
    
    var dashboardData: DashboardResponse?
    
    
    func initCell(contentId: Int, contentAttemptId: Int? = nil, showVideoProgress:Bool = false) {
        
        if (contentAttemptId != nil && showVideoProgress) {
            let contentAttempt = dashboardData?.getChapterContentAttempt(id: contentAttemptId!)
   
            if (showVideoProgress) {
                showVideoProgressBar(contentAttempt)
            }

        }
        let content = dashboardData?.getContent(id: contentId)
        let chapter = dashboardData?.getChapter(id: content!.chapterId)
        if (content?.videoId != -1) {
            playIcon.isHidden = false
            infoLayout.isHidden = true
            
        } else if (content?.examId != -1) {
            playIcon.isHidden = true
            infoLayout.isHidden = false
            infoSubtitle.isHidden = false
            let exam = dashboardData?.getExam(id: content!.examId)
            if (exam != nil) {
                showExamText(exam: exam!)
            }
        } else if(content?.htmlContentId != -1) {
            playIcon.isHidden = true
            infoLayout.isHidden = false
            let htmlContent = dashboardData?.getHtmlContent(id: content!.htmlContentId)
            if (htmlContent != nil) {
                infoTitle.text = "\(htmlContent?.readTime)"
                infoSubtitle.isHidden = true
            }
        }
        let chapterName = chapter?.name ?? ""
        setChapterTitle(title: " " + chapterName + " ")
        contentTitle.text = content?.name
        contentTypeIcon.image = Images.VideoIconSmall.image
        image.kf.setImage(with: URL(string: content?.coverImageMedium ?? ""))
    }
        
    func showExamText(exam: Exam) {
        infoTitle.text = "\(exam.numberOfQuestions)"
        infoSubtitle.text = "questions"
    }

    func showVideoProgressBar(_ contentAttempt: ChapterContentAttempt?) {
        if (contentAttempt?.userVideoId != nil) {
            videoWatchProgress.isHidden = false
            let videoAttempt = dashboardData?.getVideoAttempt(id: contentAttempt!.userVideoId!)
            let lastPosition = (videoAttempt?.lastPosition as NSString?)?.floatValue ?? 0.0
            let totalDuration = videoAttempt?.videoContent.duration ?? 0
            let watchPercentage = (Float(lastPosition)/Float(totalDuration))
            
            videoWatchProgress.progress = Float(watchPercentage)
        }
    }
    
    func setChapterTitle(title: String) {
        let myString = title
        var multipleAttributes = [NSAttributedString.Key : Any]()
        multipleAttributes[NSAttributedString.Key.backgroundColor] = Colors.getRGB("#e6e6e6")
        let myAttrString = NSAttributedString(string: myString, attributes: multipleAttributes)
        chapterTitle.attributedText = myAttrString
    }
}

