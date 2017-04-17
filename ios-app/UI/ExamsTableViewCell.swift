//
//  ExamsTableViewCell.swift
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

class ExamsTableViewCell: UITableViewCell {

    @IBOutlet weak var examName: UILabel!
    @IBOutlet weak var examViewCell: UIView!
    
    var parentViewController: UIViewController? = nil
    var exam: Exam?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tappedMe))
        examViewCell.addGestureRecognizer(tap)
    }
    
    func setExam(_ exam: Exam, viewController: UIViewController){
        parentViewController = viewController
        self.exam = exam
        examName.text = exam.title
    }
    
    func tappedMe() {
        let storyboard = UIStoryboard(name: "TestEngine", bundle: nil)
        let someViewConroller = storyboard.instantiateViewController(withIdentifier: "StartExamScreenViewController") as! StartExamScreenViewController
        someViewConroller.exam = self.exam!
        parentViewController?.showDetailViewController(someViewConroller, sender: self)
    }
    
}
