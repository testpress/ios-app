//
//  ContentPager.swift
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

class ContentPager: BasePager<ContentsListResponse, Content> {
    var url: String!
    
    var videos = [Int: Video]()
    var attachments = [Int: Attachment]()
    var notes = [Int: HtmlContent]()
    var streams = [Int: [Stream]]()
    var exams = [Int: Exam]()
    
    override func getResponse(page: Int) {
        queryParams.updateValue(String(page), forKey: Constants.PAGE)
        TPApiClient.getListItems(
            type: ContentsListResponse.self,
            endpointProvider: TPEndpointProvider(.getContents, url: url, queryParams: queryParams),
            completion: responseHandler!
        )
    }
    
    override func getItems(_ resultResponse: ContentsListResponse) -> [Content] {
        let contents: [Content] = resultResponse.contents
        
        if (!contents.isEmpty) {
            response?.results.streams.forEach { stream in
                if(streams[stream.videoId] == nil) {
                    streams.updateValue([stream], forKey: stream.videoId)
                } else {
                    var existingStreams = streams[stream.videoId]
                    existingStreams!.append(stream)
                    streams.updateValue(existingStreams!, forKey: stream.videoId)
                }
            }
            
            response?.results.videos.forEach { video in
                videos.updateValue(video, forKey: video.id)
            }
            
            response?.results.attachements.forEach { attachement in
                attachments.updateValue(attachement, forKey: attachement.id)
            }
            
            response?.results.notes.forEach { note in
                notes.updateValue(note, forKey: note.id)
            }
            
            response?.results.exams.forEach { exam in
                exams.updateValue(exam, forKey: exam.id)
            }
        }
        return contents
    }
    
    override func getId(resource: Content) -> Int {
        return resource.id
    }
    
    override func register(resource content: Content) -> Content? {
        if content.videoId != -1 {
            content.video = videos[content.videoId]
            content.video?.streams.append(objectsIn: streams[content.videoId] ?? [])
        } else if content.attachmentId != -1 {
            content.attachment = attachments[content.attachmentId]
        } else if content.htmlContentId != -1 {
            content.htmlObject = notes[content.htmlContentId]
            content.htmlContentTitle = content.htmlObject?.title
        } else if content.examId != -1 {
            content.exam = exams[content.examId]
        }
        return content
    }
    
    override func clearValues() {
        super.clearValues()
        resetValues(of: [videos, attachments, streams, notes, exams])
    }
    
}
