//
//  IndividualSubjectAnalyticsViewController.swift
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

class IndividualSubjectAnalyticsViewController: UITableViewController {
    
    var analyticsUrl: String!
    var subjects = [Subject]()
    
    override func viewDidLoad() {
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subjects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
        UITableViewCell {
            
        if subjects.count <= indexPath.row {
            // Needed to prevent index out of bound execption when dismiss view controller while
            // table view is scrolling
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.INDIVIDUAL_SUBJECT_ANALYTICS_TABLE_VIEW_CELL, for: indexPath)
            as! IndividualSubjectAnalyticsTableViewCell
        
        cell.initCell(subject: subjects[indexPath.row], parentViewController: self)
        UIUtils.setTableCellSeperatorInset(cell, size: 0)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) ->
        IndexPath? {
            
        let subject = subjects[indexPath.row]
        return subject.leaf ? nil : indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let subject = subjects[indexPath.row]
        if !subject.leaf {
            let viewController = storyboard?.instantiateViewController(
                withIdentifier: Constants.SUBJECT_ANALYTICS_TAB_VIEW_CONTROLLER)
                as! SubjectAnalyticsTabViewController
            
            viewController.analyticsUrl = analyticsUrl
            viewController.parentSubjectId = String(subject.id)
            showDetailViewController(viewController, sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) ->
        UIView? {
            
        if subjects.isEmpty {
            return nil
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectAnalyticsHeader")!
        UIUtils.setTableCellSeperatorInset(cell, size: 0)
        return cell
    }
    
}

extension IndividualSubjectAnalyticsViewController: IndicatorInfoProvider {
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: Strings.INDIVIDUAL_SUBJECTS_ANALYTICS)
    }
}
