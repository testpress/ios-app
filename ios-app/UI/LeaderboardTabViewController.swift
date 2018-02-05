//
//  LeaderboardTabViewController.swift
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

class LeaderboardTabViewController: ButtonBarPagerTabStripViewController {
    
    @IBOutlet weak var contentView: UIStackView!
    
    var activityIndicator: UIActivityIndicatorView!
    var emptyView: EmptyView!
    var userReputation: Reputation!
    
    override func viewDidLoad() {
        
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = Colors.getRGB(Colors.PRIMARY)
        settings.style.buttonBarItemFont = UIFont(name: "Helvetica-Bold", size: 12)!
        settings.style.selectedBarHeight = 4.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = Colors.getRGB(Colors.TAB_TEXT_COLOR)
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?,
            progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = Colors.getRGB(Colors.TAB_TEXT_COLOR)
            newCell?.label.textColor = Colors.getRGB(Colors.PRIMARY)
        }
        
        super.viewDidLoad()
        buttonBarView.isHidden = true
        emptyView = EmptyView.getInstance(parentView: contentView)
        activityIndicator = UIUtils.initActivityIndicator(parentView: contentView)
        activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y - 30)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if userReputation == nil {
            loadUserReputation()
        }
    }
    
    func loadUserReputation() {
        activityIndicator.startAnimating()
        
        TPApiClient.request(
            type: Reputation.self,
            endpointProvider: TPEndpointProvider(.getRank),
            completion: { reputation, error in
                
                if let error = error {
                    debugPrint(error.message ?? "No error")
                    debugPrint(error.kind)
                    var retryButtonText: String?
                    var retryHandler: (() -> Void)?
                    if error.kind == .network {
                        retryButtonText = Strings.TRY_AGAIN
                        retryHandler = {
                            self.emptyView.hide()
                            self.loadUserReputation()
                        }
                    }
                    self.activityIndicator.stopAnimating()
                    let (image, title, description) = error.getDisplayInfo()
                    
                    self.emptyView.show(image: image, title: title, description: description,
                                        retryButtonText: retryButtonText, retryHandler: retryHandler)
                    
                    return
                }
                
                self.userReputation = reputation
                self.activityIndicator.stopAnimating()
                self.buttonBarView.isHidden = false
                self.reloadPagerTabStripView()
        })
    }
    
    // MARK: - PagerTabStripDataSource
    
    override func viewControllers(
        for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let leaderboardTableViewController = LeaderboardTableViewController()
        leaderboardTableViewController.userReputation = userReputation
        
        let targerThreadViewController = TargetThreadViewController()
        targerThreadViewController.userReputation = userReputation
        
        return [leaderboardTableViewController, targerThreadViewController]
    }
    
    @IBAction func showProfileDetails(_ sender: UIBarButtonItem) {
        UIUtils.showProfileDetails(self)
    }
    
}
