//
//  TargetThreatViewController.swift
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
import UIKit
import XLPagerTabStrip
import CourseKit

class TargetThreatViewController: BaseTableViewController<Reputation>, BaseTableViewDelegate,
    IndicatorInfoProvider {
    
    var userReputation: Reputation?
    var startingRank: Int = 1
    
   open override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewDelegate = self
        
        tableView.register(
            UINib(nibName: Constants.LEADERBOARD_TABLE_VIEW_CELL, bundle: Bundle.main),
            forCellReuseIdentifier: Constants.LEADERBOARD_TABLE_VIEW_CELL
        )
        tableView.rowHeight = 80
        tableView.allowsSelection = false
        
        tableView.separatorStyle = .none
    }
    
    func loadItems() {
        // Load targets
        TPApiClient.getListItems(
            endpointProvider: TPEndpointProvider(.getTargets),
            completion: { response, error in
                if let error = error {
                    debugPrint(error.message ?? "No error")
                    debugPrint(error.kind)
                    self.handleError(error)
                    return
                }
                
                let items = response!.results.reversed()
                self.items.append(contentsOf: items)
                if self.userReputation != nil {
                    self.items.append(self.userReputation!)
                    self.startingRank = self.userReputation!.rank - items.count
                }
                self.loadThreats()
            },
            type: Reputation.self
        )
    }
    
    func loadThreats() {
        TPApiClient.getListItems(
            endpointProvider: TPEndpointProvider(.getThreats),
            completion: { response, error in
                if let error = error {
                    debugPrint(error.message ?? "No error")
                    debugPrint(error.kind)
                    self.handleError(error)
                    return
                }
                
                let items = response!.results.reversed()
                self.items.append(contentsOf: items)
                self.onLoadFinished(items: self.items)
            },
            type: Reputation.self
        )
    }
    
    // MARK: - Table view data source
    override func tableViewCell(cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.LEADERBOARD_TABLE_VIEW_CELL,
            for: indexPath
            ) as! LeaderboardTableViewCell
        
        cell.initCell(reputation: items[indexPath.row],
                      rank: startingRank + indexPath.row,
                      userId: userReputation?.user.id)
        return cell
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: Strings.TARGETS_AND_THREATS)
    }

}
