//
//  OfflineDownloadsViewController.swift
//  CourseKit
//
//  Created by Prithuvi on 07/11/24.
//  Copyright © 2024 Testpress. All rights reserved.
//

import Foundation
import Combine
import TPStreamsSDK
import UIKit

public class OfflineDownloadsViewController: BaseUIViewController, ObservableObject {
    
    @IBOutlet weak var offlineDownloadstableView: UITableView!
    @IBOutlet weak var emptyContainer: UIView!
    private var previousAssets: [OfflineAsset] = []
    @Published var offlineAssets: [OfflineAsset] = []
    var cancellables: Set<AnyCancellable> = []
    var contents: [Content] = []
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        self.setupTPStreamsDownloadManager()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupTPStreamsDownloadManager()
    }
    
    @objc func handleOfflineAssetsUpdated() {
        getOfflineAssets()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contents = getItemsFromDb(withUUIDs: offlineAssets.map { $0.assetId })
    }
    
    func setupTPStreamsDownloadManager() {
        TPStreamsDownloadManager.shared.setTPStreamsDownloadDelegate(tpStreamsDownloadDelegate: self)
        NotificationCenter.default.addObserver(self, selector: #selector(handleOfflineAssetsUpdated), name: Notification.Name("OfflineAssetsUpdated"), object: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        initializeDownloadManager()
        offlineDownloadstableView.delegate = self
        offlineDownloadstableView.dataSource = self
        offlineDownloadstableView.reloadData()
        showOrHideListView()
    }
    
    func initializeDownloadManager() {
        $offlineAssets
            .receive(on: DispatchQueue.main)
            .sink { [weak self] assets in
                self?.handleAssetChange(newAssets: assets)
            }
            .store(in: &cancellables)
        getOfflineAssets()
    }

    private func handleAssetChange(newAssets: [OfflineAsset]) {
        guard previousAssets.count != newAssets.count else {
            reloadChangedAssets(newAssets)
            return
        }
        updateAssets(newAssets)
    }

    private func updateAssets(_ newAssets: [OfflineAsset]) {
        previousAssets = newAssets
        offlineDownloadstableView.reloadData()
        showOrHideListView()
    }

    private func reloadChangedAssets(_ newAssets: [OfflineAsset]) {
        let changedIndices = findChangedIndices(oldAssets: previousAssets, newAssets: newAssets)
        previousAssets = newAssets
        let indexPaths = changedIndices.map { IndexPath(row: $0, section: 0) }
        offlineDownloadstableView.reloadRows(at: indexPaths, with: .automatic)
        showOrHideListView()
    }
    
    private func findChangedIndices(oldAssets: [OfflineAsset], newAssets: [OfflineAsset]) -> [Int] {
        var changedIndices = [Int]()
        for (index, newAsset) in newAssets.enumerated() {
            if index >= oldAssets.count || oldAssets[index] != newAsset {
                changedIndices.append(index)
            }
        }
        return changedIndices
    }
    
    func showOrHideListView() {
        if offlineAssets.isEmpty {
            emptyContainer.isHidden = false
            offlineDownloadstableView.isHidden = true
        } else {
            emptyContainer.isHidden = true
            offlineDownloadstableView.isHidden = false
        }
    }
    
    func getItemsFromDb(withUUIDs uuids: [String]) -> [Content] {
        return DBManager<Content>().getItemsFromDB().filter { content in
            uuids.contains(content.uuid ?? "")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("OfflineAssetsUpdated"), object: nil)
    }
}

extension OfflineDownloadsViewController: TPStreamsDownloadDelegate {
    
    func getOfflineAssets() {
        offlineAssets = TPStreamsDownloadManager.shared.getAllOfflineAssets()
    }

    private func updateOfflineAsset(_ offlineAsset: OfflineAsset) {
        if let index = offlineAssets.firstIndex(where: { $0.assetId == offlineAsset.assetId }) {
            offlineAssets[index] = offlineAsset
        }
    }
    
    public func onComplete(offlineAsset: OfflineAsset) {
        updateOfflineAsset(offlineAsset)
    }
    
    public func onStart(offlineAsset: OfflineAsset) {
        getOfflineAssets()
    }
    
    public func onPause(offlineAsset: OfflineAsset) {
        updateOfflineAsset(offlineAsset)
    }
    
    public func onResume(offlineAsset: OfflineAsset) {
        updateOfflineAsset(offlineAsset)
    }
    
    public func onCanceled(assetId: String) {
        if let index = offlineAssets.firstIndex(where: { $0.assetId == assetId }) {
            offlineAssets.remove(at: index)
        }
    }
    
    public func onDelete(assetId: String) {
        if let index = offlineAssets.firstIndex(where: { $0.assetId == assetId }) {
            offlineAssets.remove(at: index)
        }
    }
    
    public func onProgressChange(assetId: String, percentage: Double) {
        if let index = offlineAssets.firstIndex(where: { $0.assetId == assetId }) {
            offlineAssets[index].percentageCompleted = percentage
        }
    }
    
    public func onStateChange(status: Status, offlineAsset: OfflineAsset) {
        updateOfflineAsset(offlineAsset)
    }
}

extension OfflineDownloadsViewController: UITableViewDelegate, UITableViewDataSource, OfflineDownloadTableViewCellDelegate {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return offlineAssets.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "offlineDownloadCell", for: indexPath) as? OfflineDownloadTableViewCell else {
            return UITableViewCell()
        }
        
        let offlineAsset = offlineAssets[indexPath.row]
        cell.configure(with: offlineAsset)
        cell.delegate = self
        return cell
    }
    
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let asset = self.offlineAssets[indexPath.row]
        
        if asset.status == Status.finished.rawValue {
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
                TPStreamsDownloadManager.shared.deleteDownload(asset.assetId)
                completionHandler(true)
            }
            deleteAction.backgroundColor = .red
            return UISwipeActionsConfiguration(actions: [deleteAction])
        } else {
            return nil
        }
    }
    
    func didTapItem(for assetId: String) {
        let storyboard = UIStoryboard(name: Constants.CHAPTER_CONTENT_STORYBOARD, bundle: TestpressCourse.bundle)
        let contentDetailViewController = storyboard.instantiateViewController(
            withIdentifier: Constants.CONTENT_DETAIL_PAGE_VIEW_CONTROLLER)
            as! ContentDetailPageViewController
        let content = contents.first(where: { content in content.uuid == assetId })
        contentDetailViewController.contents = contents
        contentDetailViewController.title = content?.name
        contentDetailViewController.position = 0
        self.present(contentDetailViewController, animated: true, completion: nil)
    }
}
