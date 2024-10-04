//
//  DashboardViewController.swift
//  ios-app
//
//  Created by Karthik on 29/04/21.
//  Copyright © 2021 Testpress. All rights reserved.
//

import UIKit
import IGListKit
import CourseKit

class DashboardViewController: UIViewController {
    let repository = DashboardRepository()
    var sections = [DashboardSection]()
    var dashboardData: DashboardResponse?

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    
    @IBAction func onProfileButtonClick(_ sender: Any) {
        UIUtils.showProfileDetails(self)
    }
    
    override func viewDidLoad() {
        repository.get(completion: { response, error in
            self.sections = response?.getAvailableSections() ?? []
            self.dashboardData = response
            self.adapter.performUpdates(animated: true)
        })
        self.view.addSubview(self.collectionView)
        self.adapter.collectionView = self.collectionView
        self.adapter.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        collectionView.backgroundColor = Colors.getRGB("#f4f4f4")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        repository.refresh { response, error in
            self.sections = response?.getAvailableSections() ?? []
            self.dashboardData = response
            self.adapter.performUpdates(animated: true)
        }
    }
}


extension DashboardViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return sections as [ListDiffable]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        
        let currentSection = object as? DashboardSection
        if (currentSection?.contentType == "trophy_leaderboard") {
            let sectionController = LeaderboardSectionController()
            sectionController.dashboardData = dashboardData
            sectionController.currentSection = currentSection
            return sectionController
        }
        
        let carouselSectionController = CarouselSectionController()
        carouselSectionController.sections = sections
        carouselSectionController.currentSection = object as? DashboardSection
        carouselSectionController.dashboardData = dashboardData
        return carouselSectionController
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        let emptyView = EmptyView.getInstance()
       emptyView.setValues(image: Images.Dinosaur.image, title: "Oh Snap!!", description: "Nothing Here, But Me",
                            retryHandler: nil)
        return emptyView
    }
}
