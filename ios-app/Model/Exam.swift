//
//  Exam.swift
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

public class Exam {
    var url: String?;
    var id: Int?;
    var title: String?;
    var description: String?;
    var startDate: String?;
    var endDate: String?;
    var duration: String?;
    var numberOfQuestions: Int?;
    var negativeMarks: String?;
    var markPerQuestion: String?;
    var templateType: Int?;
    var allowRetake: Bool?;
    var maxRetakes: Int?;
    var enableRanks: Bool?;
    var rankPublishingDate: String?;
    var attemptsUrl: String?;
    var attemptsCount: Int?;
    var pausedAttemptsCount: Int?;
    var allowPdf: Bool?;
    var allowQuestionPdf: Bool?;
    var created: String?;
    var slug: String?;
    var variableMarkPerQuestion: Bool?;
    var showAnswers: Bool?;
    var commentsCount: Int?;
    var allowPreemptiveSectionEnding: Bool?;
    var immediateFeedback: Bool?;
    var deviceAccessControl: String?;
    
    public required init?(map: Map) {
    }
}

extension Exam: TestpressModel {
    public func mapping(map: Map) {
        url <- map["url"]
        id <- map["id"]
        title <- map["title"]
        description <- map["description"]
        startDate <- map["startDate"]
        endDate <- map["endDate"]
        duration <- map["duration"]
        numberOfQuestions <- map["numberOfQuestions"]
        templateType <- map["templateType"]
        allowRetake <- map["allowRetake"]
        maxRetakes <- map["maxRetakes"]
        enableRanks <- map["enableRanks"]
        rankPublishingDate <- map["rankPublishingDate"]
        attemptsUrl <- map["attemptsUrl"]
        attemptsCount <- map["attemptsCount"]
        pausedAttemptsCount <- map["pausedAttemptsCount"]
        allowPdf <- map["allowPdf"]
        allowQuestionPdf <- map["allowQuestionPdf"]
        created <- map["created"]
        slug <- map["slug"]
        variableMarkPerQuestion <- map["variableMarkPerQuestion"]
        showAnswers <- map["showAnswers"]
        commentsCount <- map["commentsCount"]
        allowPreemptiveSectionEnding <- map["allowPreemptiveSectionEnding"]
        immediateFeedback <- map["immediateFeedback"]
        deviceAccessControl <- map["deviceAccessControl"]
    }
}
