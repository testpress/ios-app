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
    @Published var offlineAssets: [OfflineAsset] = []
    var cancellables: Set<AnyCancellable> = []
    
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
                self?.offlineDownloadstableView.reloadData()
                self?.showOrHideListView()
            }
            .store(in: &cancellables)
        getOfflineAssets()
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
    
    
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("OfflineAssetsUpdated"), object: nil)
    }
}

extension OfflineDownloadsViewController: TPStreamsDownloadDelegate {
    
    func getOfflineAssets() {
        offlineAssets = TPStreamsDownloadManager.shared.getAllOfflineAssets()
    }
    
    public func onComplete(offlineAsset: OfflineAsset) {
        getOfflineAssets()
    }
    
    public func onStart(offlineAsset: OfflineAsset) {
        getOfflineAssets()
    }
    
    public func onPause(offlineAsset: OfflineAsset) {
        
    }
    
    public func onResume(offlineAsset: OfflineAsset) {
        
    }
    
    public func onCanceled(assetId: String) {
        getOfflineAssets()
    }
    
    public func onDelete(assetId: String) {
        getOfflineAssets()
    }
    
    public func onProgressChange(assetId: String, percentage: Double) {
        getOfflineAssets()
    }
    
    public func onStateChange(status: Status, offlineAsset: OfflineAsset) {
        func updateOfflineAsset(_ offlineAsset: OfflineAsset) {
            if let index = offlineAssets.firstIndex(where: { $0.assetId == offlineAsset.assetId }) {
                offlineAssets[index] = offlineAsset
            }
        }
    }
}

extension OfflineDownloadsViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return offlineAssets.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "offlineDownloadCell", for: indexPath) as? OfflineDownloadTableViewCell else {
            return UITableViewCell()
        }
        
        let offlineAsset = offlineAssets[indexPath.row]
        cell.configure(with: offlineAsset)
        return cell
    }

}

class OfflineDownloadTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var details: UILabel!
    @IBOutlet weak var deleteButton: UIImageView!
    @IBOutlet weak var cancelButton: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var containerCell: UIView!
    var offlineAsset : OfflineAsset?
    
    func configure(with asset: OfflineAsset) {
        offlineAsset = asset
        title.text = asset.title
        details.text = "\(TimeUtils.formatDate(date: asset.createdAt)) • \(TimeUtils.formatDuration(seconds: asset.duration)) • \(String(format: "%.2f MB", asset.size / 8 / 1024 / 1024))"
        
        if asset.status == Status.inProgress.rawValue {
            let progress = (asset.percentageCompleted / 100)
            progressView.isHidden = false
            progressView.progress = Float(progress)
            cancelButton.isHidden = false
            deleteButton.isHidden = true
        } else if asset.status == Status.finished.rawValue {
            progressView.isHidden = true
            cancelButton.isHidden = true
            deleteButton.isHidden = false
        }
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onItemClick))
        containerCell.addGestureRecognizer(tapRecognizer)
        
        deleteButton.addTapGestureRecognizer {
            TPStreamsDownloadManager.shared.deleteDownload(asset.assetId)
        }
        
        cancelButton.addTapGestureRecognizer {
            TPStreamsDownloadManager.shared.cancelDownload(asset.assetId)
        }
    }
    
    @objc func onItemClick() {
        // Open Player view
    }
}
