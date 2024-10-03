//
//  BookmarksPager.swift
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

import Alamofire
import ObjectMapper
import CourseKit

class BookmarksPager: BasePager<BookmarksListResponse, Bookmark> {
    
    var contentTypes = [Int: ContentType]()
    var folders = [Int: BookmarkFolder]()
    
    var reviewItems = [Int: AttemptItem]()
    var questions = [Int: AttemptQuestion]()
    var answers = [Int: AttemptAnswer]()
    var translations = [Int: AttemptQuestion]()
    var answerTranslations = [Int: AttemptAnswer]()
    
    var directions = [Int: Direction]()
    var subjects = [Int: Subject]()
    
    var contents = [Int: Content]()
    var htmlContents = [Int: HtmlContent]()
    var videos = [Int: Video]()
    var streams = [Int: [Stream]]()
    var attachments = [Int: Attachment]()
    
    var folder: String!
    
    override func getResponse(page: Int) {
        queryParams.updateValue(String(page), forKey: Constants.PAGE)
        if folder != nil {
            if folder == BookmarkFolder.UNCATEGORIZED {
                queryParams.updateValue("", forKey: "folder")
            } else {
                queryParams.updateValue(folder, forKey: "folder")
            }
        } else if queryParams["folder"] != nil {
            queryParams["folder"] = nil
        }
        TPApiClient.getListItems(
            type: BookmarksListResponse.self,
            endpointProvider: TPEndpointProvider(.bookmarks, queryParams: queryParams),
            completion: responseHandler!
        )
    }
    
    override func getItems(_ resultResponse: BookmarksListResponse) -> [Bookmark] {
        let bookmarks: [Bookmark] = resultResponse.bookmarks
        if !bookmarks.isEmpty {
            response!.results.folders.forEach { folder in
                folders.updateValue(folder, forKey: folder.id)
            }
            response!.results.contentTypes.forEach { contentType in
                contentTypes.updateValue(contentType, forKey: contentType.id)
            }
            
            response!.results.userSelectedAnswers.forEach { reviewItem in
                reviewItems.updateValue(reviewItem, forKey: reviewItem.id)
            }
            response!.results.questions.forEach { question in
                questions.updateValue(question, forKey: question.id)
            }
            response!.results.answers.forEach { answer in
                answers.updateValue(answer, forKey: answer.id)
            }
            response!.results.translations.forEach { translation in
                translations.updateValue(translation, forKey: translation.id)
            }
            response!.results.answerTranslations.forEach { answerTranslation in
                answerTranslations.updateValue(answerTranslation, forKey: answerTranslation.id)
            }
            
            response!.results.directions.forEach { direction in
                directions.updateValue(direction, forKey: direction.id)
            }
            response!.results.subjects.forEach { subject in
                subjects.updateValue(subject, forKey: subject.id)
            }
            
            response!.results.chapterContents.forEach { content in
                contents.updateValue(content, forKey: content.id)
            }
            response!.results.htmlContents.forEach { htmlContent in
                htmlContents.updateValue(htmlContent, forKey: htmlContent.id)
            }
            
            self.storeStreams()
            response!.results.videos.forEach { video in
                videos.updateValue(video, forKey: video.id)
            }
            response!.results.attachments.forEach { attachment in
                attachments.updateValue(attachment, forKey: attachment.id)
            }
        }
        return bookmarks
    }
    
    func storeStreams() {
        response?.results.streams.forEach { stream in
            if(streams[stream.videoId] == nil) {
                streams.updateValue([stream], forKey: stream.videoId)
            } else {
                var existingStreams = streams[stream.videoId]
                existingStreams!.append(stream)
                streams.updateValue(existingStreams!, forKey: stream.videoId)
            }
        }
    }
    
    override func register(resource bookmark: Bookmark) -> Bookmark? {
        
        if bookmark.folderId != 0 {
            bookmark.folder = folders[bookmark.folderId]!.name
        }
        
        switch contentTypes[bookmark.contentTypeId]!.model {
        case "userselectedanswer":
            let reviewItem = reviewItems[bookmark.objectId]!
            reviewItem.question = questions[reviewItem.questionId]!.clone()
            for answerId in reviewItem.question.answerIds {
                reviewItem.question.answers.append(answers[answerId]!)
            }
            if reviewItem.question.directionId != -1{
                reviewItem.question.direction = directions[reviewItem.question.directionId]?.html
            }
            if reviewItem.question.subjectId != -1{
                reviewItem.question.subject = subjects[reviewItem.question.subjectId]?.name ?? "Uncategorized"
            }
            bookmark.bookmarkedObject = reviewItem
            break
        case "chaptercontent":
            let content = contents[bookmark.objectId]!
            if content.videoId != -1 {
                content.video = videos[content.videoId]!
                content.video?.streams.append(objectsIn: streams[content.videoId] ?? [])
            } else if content.attachmentId != -1 {
                content.attachment = attachments[content.attachmentId]!
            } else if content.htmlContentId != -1 {
                content.htmlObject = htmlContents[content.htmlContentId]
                content.htmlContentTitle = content.htmlObject?.title
            }
            bookmark.bookmarkedObject = content
            break
        default:
            break
        }
        
        return bookmark
    }
    
    override func getId(resource: Bookmark) -> Int {
        return resource.id
    }
    
    override func clearValues() {
        super.clearValues()
        resetValues(of: [contentTypes, folders, reviewItems, questions, answers, translations,
                         answerTranslations, contents, htmlContents, videos, attachments,
                         directions, subjects])
    }
    
}
