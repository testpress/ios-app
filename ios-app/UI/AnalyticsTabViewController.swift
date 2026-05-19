//
//  AnalyticsTabViewController.swift
//  ios-app
//
//  Copyright © 2024 Testpress. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import CourseKit

class AnalyticsTabViewController: ButtonBarPagerTabStripViewController {

    @IBOutlet weak var contentView: UIView!

    var activityIndicator: UIActivityIndicatorView!
    var emptyView: EmptyView!
    private var analyticsUrl: String!
    var subjects: [Subject] = []
    var hasLoaded = false
    let loader = AnalyticsLoader()

    override func viewDidLoad() {
        self.setStatusBarColor()
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = TestpressCourse.shared.primaryColor
        settings.style.buttonBarItemFont = UIFont(name: "Helvetica-Bold", size: 12) ?? UIFont.boldSystemFont(ofSize: 12)
        settings.style.selectedBarHeight = 4.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = Colors.getRGB(Colors.TAB_TEXT_COLOR)
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0

        changeCurrentIndexProgressive = { [weak self] (oldCell, newCell, progressPercentage, changeCurrentIndex, animated) in
            guard let self = self, changeCurrentIndex else { return }
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

        if !hasLoaded {
            analyticsUrl = TestpressCourse.shared.baseURL + TPEndpoint.getSubjectAnalytics.urlPath
            loadSubjects()
        }
    }

    func loadSubjects() {
        activityIndicator.startAnimating()
        loader.load(analyticsUrl: analyticsUrl) { [weak self] subjects, error in
            guard let self = self else { return }

            self.activityIndicator.stopAnimating()

            if let error = error {
                var retryButtonText: String?
                var retryHandler: (() -> Void)?
                if error.kind == .network {
                    retryButtonText = Strings.TRY_AGAIN
                    retryHandler = { [weak self] in
                        guard let self = self else { return }
                        self.emptyView.hide()
                        self.loader.reset()
                        self.loadSubjects()
                    }
                }
                let (image, title, description) = error.getDisplayInfo()
                self.emptyView.show(image: image, title: title, description: description,
                                    retryButtonText: retryButtonText, retryHandler: retryHandler)
                return
            }

            guard let subjects = subjects, !subjects.isEmpty else {
                self.emptyView.show(
                    image: Images.AnalyticsFlatIcon.image,
                    title: Strings.NO_ANALYTICS,
                    description: Strings.NO_SUBJECT_ANALYTICS_DESCRIPTION
                )
                return
            }

            self.hasLoaded = true
            self.subjects = subjects.sorted(by: { ($0.name ?? "") < ($1.name ?? "") })
            self.buttonBarView.isHidden = false
            self.reloadPagerTabStripView()
        }
    }

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) ->
        [UIViewController] {

        let bundle = Bundle(for: OverallSubjectAnalyticsViewController.self)
        let storyboard = UIStoryboard(name: "ExamReview", bundle: bundle)

        guard let overallAnalyticsViewController = storyboard.instantiateViewController(
            withIdentifier: Constants.OVERALL_SUBJECT_ANALYTICS_VIEW_CONTROLLER)
            as? OverallSubjectAnalyticsViewController,
            let individualAnalyticsViewController = storyboard.instantiateViewController(
            withIdentifier: Constants.INDIVIDUAL_SUBJECT_ANALYTICS_VIEW_CONTROLLER)
            as? IndividualSubjectAnalyticsViewController
        else {
            return []
        }

        overallAnalyticsViewController.subjects = subjects
        individualAnalyticsViewController.subjects = subjects
        individualAnalyticsViewController.analyticsUrl = analyticsUrl
        return [overallAnalyticsViewController, individualAnalyticsViewController]
    }

    override func viewDidLayoutSubviews() {
        activityIndicator?.frame = contentView.frame
    }

}
