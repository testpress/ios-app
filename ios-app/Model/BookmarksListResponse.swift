//
//  BookmarksListResponse.swift
//  ios-app
//
//  Copyright © 2017 Testpress. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import ObjectMapper
import CourseKit

public class BookmarksListResponse {
    
    var bookmarks: [Bookmark] = []
    var folders: [BookmarkFolder] = []
    var contentTypes: [ContentType] = []
    
    var userSelectedAnswers: [AttemptItem] = []
    var questions: [AttemptQuestion] = []
    var answers: [AttemptAnswer] = []
    var translations: [AttemptQuestion] = []
    var answerTranslations: [AttemptAnswer] = []
    
    var directions: [Direction] = []
    var subjects: [Subject] = []
    
    var chapterContents: [Content] = []
    var htmlContents: [HtmlContent] = []
    var videos: [Video] = []
    var streams: [Stream] = []
    var attachments: [Attachment] = []
    
    public required init?(map: Map) {
        mapping(map: map)
    }
}

extension BookmarksListResponse: TestpressModel {
    
    public func mapping(map: Map) {
        bookmarks <- map["bookmarks"]
        folders <- map["folders"]
        contentTypes <- map["content_types"]
        
        userSelectedAnswers <- map["user_selected_answers"]
        questions <- map["questions"]
        answers <- map["answers"]
        translations <- map["translations"]
        answerTranslations <- map["answer_translations"]
        
        directions <- map["directions"]
        subjects <- map["subjects"]
        
        chapterContents <- map["chapter_contents"]
        htmlContents <- map["html_contents"]
        videos <- map["videos"]
        attachments <- map["attachments"]
        streams <- map["streams"]
    }
}
