//
//  IndividualSubjectAnalyticsCountCell.swift
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

import UIKit

class IndividualSubjectAnalyticsCountCell: UITableViewCell {
    
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var correct: UILabel!
    @IBOutlet weak var incorrect: UILabel!
    @IBOutlet weak var skipped: UILabel!
    @IBOutlet weak var navigationArrow: UIImageView!
    
    var subject: Subject!
    var parentViewController: UIViewController!
    
    func initCell(subject: Subject, parentViewController: UIViewController) {
        self.subject = subject
        self.parentViewController = parentViewController
        subjectLabel.text = subject.name
        correct.text = String(subject.correct)
        incorrect.text = String(subject.incorrect)
        skipped.text = String(subject.unanswered)
        if subject.leaf {
            navigationArrow.image = nil
        } else {
            navigationArrow.image = Images.NavigateNext.image
        }
    }
    
}
