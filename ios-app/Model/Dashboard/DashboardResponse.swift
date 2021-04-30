//
//  DashboardResponse.swift
//  ios-app
//
//  Created by Karthik on 29/04/21.
//  Copyright © 2021 Testpress. All rights reserved.
//

import ObjectMapper

public class DashboardResponse {
    var dashboardSections: [DashboardSection]?
    var availableSections: [DashboardSection] = []
    var chapterContents: [Content]?
    var chapterContentAttempts: [ChapterContentAttempt]?
    var posts: [Post]?
    var bannerAds: [Banner]?
    var leaderboardItems: [LeaderboardItem]?
    var chapters: [Chapter]?
    var courses: [Course]?
    var userStats: [UserStats]?
    var exams: [Exam]?
    var assessments: [Attempt]?
    var userVideos: [VideoAttempt]?
    var contents: [HtmlContent]?
    var videos: [Video]?
    var acceptedContentTypes = ["trophy_leaderboard", "banner_ad"]
    
    
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
    
    func getContent(id: Int) -> Content? {
        if contentMap.isEmpty {
            for content in chapterContents ?? [] {
                contentMap[content.id] = content
            }
        }
        
        return contentMap[id]
    }
    
    
    func getChapter(id: Int) -> Chapter? {
        if chapterMap.isEmpty {
            for chapter in chapters ?? [] {
                chapterMap[chapter.id] = chapter
            }
        }
        
        return chapterMap[id]
    }
    
    func getBanner(id: Int) -> Banner? {
        if bannerMap.isEmpty {
            for banner in bannerAds ?? [] {
                bannerMap[banner.id!] = banner
            }
        }
        
        return bannerMap[id]
    }
    
    func getPost(id: Int) -> Post? {
        if postMap.isEmpty {
            for post in posts ?? [] {
                postMap[post.id] = post
            }
        }
        
        return postMap[id]
    }
    
    func getLeaderboardItem(id: Int) -> LeaderboardItem? {
        if leaderboardItemMap.isEmpty {
            for leaderboardItem in leaderboardItems ?? [] {
                leaderboardItemMap[leaderboardItem.id!] = leaderboardItem
            }
        }
        
        return leaderboardItemMap[id]
    }
    
    func getChapterContentAttempt(id: Int) -> ChapterContentAttempt? {
        if chapterContentAttemptMap.isEmpty {
            for contentAttempt in chapterContentAttempts ?? [] {
                chapterContentAttemptMap[contentAttempt.id!] = contentAttempt
            }
        }
        
        return chapterContentAttemptMap[id]
    }
    
    func getVideoAttempt(id: Int) -> VideoAttempt? {
        if userVideosMap.isEmpty {
            for userVideo in userVideos ?? [] {
                userVideosMap[userVideo.id!] = userVideo
            }
        }
        
        return userVideosMap[id]
    }
    
    func getExam(id: Int = -1) -> Exam? {
        if examMap.isEmpty {
            for exam in exams ?? [] {
                examMap[exam.id] = exam
            }
        }
        
        return examMap[id]
    }
    
    func getHtmlContent(id: Int = -1) -> HtmlContent? {
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

