//
//  SubjectPager.swift
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

import CourseKit

class SubjectPager: TPBasePager<Subject> {
    
    let url: String
    let parentSubjectId: String
    
    init(_ analyticsUrl: String, parentSubjectId: String) {
        url = analyticsUrl
        self.parentSubjectId = parentSubjectId
        super.init()
    }
    
    override func getItems(page: Int) {
        queryParams.updateValue(parentSubjectId, forKey: Constants.PARENT)
        queryParams.updateValue(String(page), forKey: Constants.PAGE)
        TPApiClient.getListItems(
            endpointProvider: TPEndpointProvider(.get, url: url, queryParams: queryParams),
            completion: resonseHandler!,
            type: Subject.self
        )
    }
    
    override func register(resource subject: Subject) -> Subject? {
        // Discard the Subject if its Total answered count is zero
        if subject.total != 0 {
            subject.percentage = getPercentage(subject.correct, of: subject.total)
            subject.incorrectPercentage = getPercentage(subject.incorrect, of: subject.total)
            subject.unansweredPercentage = getPercentage(subject.unanswered, of: subject.total)
            return subject;
        }
        return nil;
    }
    
    func getPercentage(_ value: Int, of total: Int) -> Double {
        return Double(value) / Double(total) * 100;
    }
    
    override func getId(resource: Subject) -> Int {
        return resource.id!
    }
    
}
