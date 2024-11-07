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

class OfflineDownloadsViewController: BaseUIViewController, ObservableObject {
    
    @Published var offlineAssets: [OfflineAsset] = []
    var cancellables: Set<AnyCancellable> = []
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        TPStreamsDownloadManager.shared.setTPStreamsDownloadDelegate(tpStreamsDownloadDelegate: self)
        NotificationCenter.default.addObserver(self, selector: #selector(handleOfflineAssetsUpdated), name: Notification.Name("OfflineAssetsUpdated"), object: nil)

    }
    
    @objc func handleOfflineAssetsUpdated() {
        getOfflineAssets()
        print("Offline Assets Updated")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeDownloadManager()
    }
    
    func initializeDownloadManager() {
        $offlineAssets
            .receive(on: DispatchQueue.main)
            .sink { [weak self] assets in
                // self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("OfflineAssetsUpdated"), object: nil)
    }
    
}

extension OfflineDownloadsViewController: TPStreamsDownloadDelegate {
    
    func getOfflineAssets() {
        offlineAssets = TPStreamsDownloadManager.shared.getAllOfflineAssets()
    }
    
    func onComplete(offlineAsset: OfflineAsset) {
        getOfflineAssets()
    }
    
    func onStart(offlineAsset: OfflineAsset) {
        getOfflineAssets()
    }
    
    func onPause(offlineAsset: OfflineAsset) {
        
    }
    
    func onResume(offlineAsset: OfflineAsset) {
        
    }
    
    func onCanceled(assetId: String) {
        getOfflineAssets()
    }
    
    func onDelete(assetId: String) {
        getOfflineAssets()
    }
    
    func onProgressChange(assetId: String, percentage: Double) {
        
    }
    
    func onStateChange(status: Status, offlineAsset: OfflineAsset) {
        func updateOfflineAsset(_ offlineAsset: OfflineAsset) {
            if let index = offlineAssets.firstIndex(where: { $0.assetId == offlineAsset.assetId }) {
                offlineAssets[index] = offlineAsset
            }
        }
    }
}
