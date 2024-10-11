//
//  AccessCodeExamsViewController.swift
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
import CourseKit

class AccessCodeExamsViewController: TPBasePagedTableViewController<Exam> {
    
    let cellIdentifier = "ExamsTableViewCell"
    var accessCode: String!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(pager: ExamPager(), coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStatusBarColor()
        
        (pager as! ExamPager).accessCode = accessCode
        tableView.register(UINib(nibName: cellIdentifier, bundle: Bundle.main),
                           forCellReuseIdentifier: cellIdentifier)
        
        tableView.rowHeight = 105
        tableView.allowsSelection = false
    }
    
    // MARK: - Table view data source
    
    override func tableViewCell(cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as!
        ExamsTableViewCell
        
        cell.initExamCell(items[indexPath.row], accessCode: accessCode!, viewController: self)
        return cell
    }
    
    override func setEmptyText() {
        emptyView.setValues(image: Images.ExamsFlatIcon.image, title: Strings.NO_EXAMS,
                            description: Strings.NO_AVAILABLE_EXAM)
    }
    
    @IBAction func back() {
        dismiss(animated: true, completion: nil)
    }
    
}
