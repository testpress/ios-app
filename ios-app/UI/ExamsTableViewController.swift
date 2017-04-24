//
//  ExamsTableViewController.swift
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
import XLPagerTabStrip

enum ExamState {
    case available
    case upcoming
    case history
    
    var title: String {
        switch self {
        case .available:
            return Constants.AVAILABLE
        case .upcoming:
            return Constants.UPCOMING
        case .history:
            return Constants.HISTORY
        }
    }
    
    var slug: String {
        switch self {
        case .available:
            return Slug.AVAILABLE
        case .upcoming:
            return Slug.UPCOMING
        case .history:
            return Slug.HISTORY
        }
    }
}

class ExamsTableViewController: TPBasePagedTableViewController<Exam>, IndicatorInfoProvider {

    let cellIdentifier = "ExamsTableViewCell"
    let state: ExamState
    
    init(state: ExamState) {
        self.state = state
        super.init(pager: ExamPager(subclass: state.slug))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: cellIdentifier, bundle: Bundle.main),
                           forCellReuseIdentifier: cellIdentifier)
        tableView.rowHeight = 105
        tableView.allowsSelection = false
    }
    
    // MARK: - Table view data source
    
    override func tableViewCell(cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as!
            ExamsTableViewCell
        
        cell.setExam(items[indexPath.row], examState: state, viewController: self)
        return cell
    }

    // MARK: - IndicatorInfoProvider
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: state.title)
    }

}
