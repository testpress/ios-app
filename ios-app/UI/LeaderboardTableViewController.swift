//
//  LeaderboardTableViewController.swift
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

class LeaderboardTableViewController: TPBasePagedTableViewController<Reputation>,
    IndicatorInfoProvider {
    
    var userReputation: Reputation?
    
    required init() {
        super.init(pager: LeaderboardPager())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(
            UINib(nibName: Constants.LEADERBOARD_TABLE_VIEW_CELL, bundle: Bundle.main),
            forCellReuseIdentifier: Constants.LEADERBOARD_TABLE_VIEW_CELL
        )
        tableView.rowHeight = 80
        tableView.allowsSelection = false
                
        tableView.separatorStyle = .none
    }
    
    // MARK: - Table view data source
    override func tableViewCell(cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.LEADERBOARD_TABLE_VIEW_CELL,
            for: indexPath
        ) as! LeaderboardTableViewCell
        
        cell.initCell(reputation: items[indexPath.row],
                      rank: indexPath.row + 1,
                      userId: userReputation?.user.id)
        return cell
    }
    
    override func setEmptyText() {
        emptyView.setValues(image: Images.LeaderboardFlatIcon.image,
                            title: Strings.NO_LEADERBOARD_ITEMS,
                            description: Strings.NO_LEADERBOARD_ITEMS_DESCRIPTION)
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: Strings.LEADERBOARD)
    }
    
}
