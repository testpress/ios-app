//
//  DashboardResponse.swift
//  ios-app
//
//  Created by Karthik on 29/04/21.
//  Copyright © 2021 Testpress. All rights reserved.
//

import ObjectMapper

public class DashboardResponse {
    public var dashboardSections: [DashboardSection]?
    public var availableSections: [DashboardSection] = []
    public var chapterContents: [Content]?
    public var chapterContentAttempts: [ChapterContentAttempt]?
    public var posts: [Post]?
    public var bannerAds: [Banner]?
    public var leaderboardItems: [LeaderboardItem]?
    public var chapters: [Chapter]?
    public var courses: [Course]?
    public var userStats: [UserStats]?
    public var exams: [Exam]?
    public var assessments: [Attempt]?
    public var userVideos: [VideoAttempt]?
    public var contents: [HtmlContent]?
    public var videos: [Video]?
    public var acceptedContentTypes = ["trophy_leaderboard", "banner_ad", "post",
    "chapter_content", "chapter_content_attempt"]
    
    
    private var contentMap = [Int: Content]()
    private var chapterMap = [Int: Chapter]()
    private var bannerMap = [Int: Banner]()
    private var postMap = [Int: Post]()
    private var leaderboardItemMap = [Int: LeaderboardItem]()
    private var chapterContentAttemptMap = [Int: ChapterContentAttempt]()
    private var userVideosMap = [Int: VideoAttempt]()
    private var examMap = [Int: Exam]()
    private var htmlContentMap = [Int: HtmlContent]()

    public required init?(map: Map) {
        
    }
    
    
    public func getAvailableSections() -> [DashboardSection] {
        if (availableSections.isEmpty) {
            for section in dashboardSections! {
                if(acceptedContentTypes.contains(section.contentType!) && (section.items?.isEmpty == false)) {
                    availableSections.append(section)
                }
            }
            availableSections.sort(by: {$0.order! < $1.order!})
        }
        
        return availableSections
    }
    
    public func getContent(id: Int) -> Content? {
        if contentMap.isEmpty {
            for content in chapterContents ?? [] {
                contentMap[content.id] = content
            }
        }
        
        return contentMap[id]
    }
    
    
    public func getChapter(id: Int) -> Chapter? {
        if chapterMap.isEmpty {
            for chapter in chapters ?? [] {
                chapterMap[chapter.id] = chapter
            }
        }
        
        return chapterMap[id]
    }
    
    public func getBanner(id: Int) -> Banner? {
        if bannerMap.isEmpty {
            for banner in bannerAds ?? [] {
                bannerMap[banner.id!] = banner
            }
        }
        
        return bannerMap[id]
    }
    
    public func getPost(id: Int) -> Post? {
        if postMap.isEmpty {
            for post in posts ?? [] {
                postMap[post.id] = post
            }
        }
        
        return postMap[id]
    }
    
    public func getLeaderboardItem(id: Int) -> LeaderboardItem? {
        if leaderboardItemMap.isEmpty {
            for leaderboardItem in leaderboardItems ?? [] {
                leaderboardItemMap[leaderboardItem.id!] = leaderboardItem
            }
        }
        
        return leaderboardItemMap[id]
    }
    
    public func getChapterContentAttempt(id: Int) -> ChapterContentAttempt? {
        if chapterContentAttemptMap.isEmpty {
            for contentAttempt in chapterContentAttempts ?? [] {
                chapterContentAttemptMap[contentAttempt.id!] = contentAttempt
            }
        }
        
        return chapterContentAttemptMap[id]
    }
    
    public func getVideoAttempt(id: Int) -> VideoAttempt? {
        if userVideosMap.isEmpty {
            for userVideo in userVideos ?? [] {
                userVideosMap[userVideo.id!] = userVideo
            }
        }
        
        return userVideosMap[id]
    }
    
    public func getExam(id: Int = -1) -> Exam? {
        if examMap.isEmpty {
            for exam in exams ?? [] {
                examMap[exam.id] = exam
            }
        }
        
        return examMap[id]
    }
    
    public func getHtmlContent(id: Int = -1) -> HtmlContent? {
        if htmlContentMap.isEmpty {
            for htmlContent in contents ?? [] {
                htmlContentMap[htmlContent.id] = htmlContent
            }
        }
        
        return htmlContentMap[id]
    }
    
}


extension DashboardResponse: TestpressModel {
    public func mapping(map: Map) {
        dashboardSections <- map["dashboard_sections"]
        chapterContents <- map["chapter_contents"]
        chapterContentAttempts <- map["chapter_content_attempts"]
        posts <- map["posts"]
        bannerAds <- map["banner_ads"]
        leaderboardItems <- map["leaderboard_items"]
        chapters <- map["chapters"]
        courses <- map["courses"]
        userStats <- map["user_stats"]
        exams <- map["exams"]
        assessments <- map["assessments"]
        userVideos <- map["user_videos"]
        contents <- map["contents"]
        videos <- map["videos"]
    }
}

