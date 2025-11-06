//
//  SubjectAnalyticsTabViewController.swift
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

class SubjectAnalyticsTabViewController: ButtonBarPagerTabStripViewController {
    
    @IBOutlet weak var contentView: UIView!
    
    var activityIndicator: UIActivityIndicatorView! // Progress bar
    var emptyView: EmptyView!
    var parentSubjectId: String!
    var analyticsUrl: String!
    var subjects: [Subject] = []
    var pager: SubjectPager!
    
    override func viewDidLoad() {
        self.setStatusBarColor()
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = TestpressCourse.shared.primaryColor
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
            newCell?.label.textColor = TestpressCourse.shared.primaryColor
        }
        
        super.viewDidLoad()
        buttonBarView.isHidden = true
        emptyView = EmptyView.getInstance(parentView: contentView)
        activityIndicator = UIUtils.initActivityIndicator(parentView: contentView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if subjects.isEmpty {
            if analyticsUrl == nil {
                analyticsUrl = TestpressCourse.shared.baseURL + TPEndpoint.getSubjectAnalytics.urlPath
            }
            loadSubjects()
        }
    }
    
    func getPager() -> SubjectPager {
        if pager == nil {
            if parentSubjectId == nil {
                parentSubjectId = "null"
            }
            pager = SubjectPager(analyticsUrl, parentSubjectId: parentSubjectId)
        }
        return pager
    }
    
    func loadSubjects() {
        activityIndicator.startAnimating()
        getPager().next(completion: {
            items, error in
            
            if let error = error {
                debugPrint(error.message ?? "No error")
                debugPrint(error.kind)
                var retryButtonText: String?
                var retryHandler: (() -> Void)?
                if error.kind == .network {
                    retryButtonText = Strings.TRY_AGAIN
                    retryHandler = {
                        self.emptyView.hide()
                        self.loadSubjects()
                    }
                }
                self.activityIndicator.stopAnimating()
                let (image, title, description) = error.getDisplayInfo()
                
                self.emptyView.show(image: image, title: title, description: description,
                                    retryButtonText: retryButtonText, retryHandler: retryHandler)
                
                return
            }
            
            if self.pager.hasMore {
                self.loadSubjects()
            } else {
                self.subjects = Array(items!.values)
                self.subjects = self.subjects.sorted(by: { $0.name! < $1.name! })
                self.activityIndicator.stopAnimating()
                if self.subjects.isEmpty {
                    self.emptyView.show(
                        image: Images.AnalyticsFlatIcon.image,
                        title: Strings.NO_ANALYTICS,
                        description: Strings.NO_SUBJECT_ANALYTICS_DESCRIPTION
                    )
                    return
                }
                self.buttonBarView.isHidden = false
                self.reloadPagerTabStripView()
            }
        })
    }
    
    // MARK: - PagerTabStripDataSource
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) ->
        [UIViewController] {
            
        let overallAnalyticsViewController = storyboard?.instantiateViewController(
            withIdentifier: Constants.OVERALL_SUBJECT_ANALYTICS_VIEW_CONTROLLER)
            as! OverallSubjectAnalyticsViewController
            
        overallAnalyticsViewController.subjects = subjects
        
        let individualAnalyticsViewController = storyboard?.instantiateViewController(
            withIdentifier: Constants.INDIVIDUAL_SUBJECT_ANALYTICS_VIEW_CONTROLLER)
            as! IndividualSubjectAnalyticsViewController
        
        individualAnalyticsViewController.subjects = subjects
        individualAnalyticsViewController.analyticsUrl = analyticsUrl
        return [overallAnalyticsViewController, individualAnalyticsViewController]
    }
    
    @IBAction func back() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        // Set frames of the view here to support both portrait & landscape view
        activityIndicator?.frame = contentView.frame
    }
    
}
