//
//  OfflineDownloadTableViewCell.swift
//  CourseKit
//
//  Created by Prithuvi on 11/11/24.
//  Copyright © 2024 Testpress. All rights reserved.
//

import Foundation
import UIKit
import TPStreamsSDK

class OfflineDownloadTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var details: UILabel!
    @IBOutlet weak var cancelButton: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var containerCell: UIView!
    var offlineAsset : OfflineAsset?
    weak var delegate: OfflineDownloadTableViewCellDelegate?
    
    func configure(with asset: OfflineAsset) {
        offlineAsset = asset
        setTitleAndDetails(for: asset)
        configureProgress(for: asset)
        setUpGestures(for: asset)
    }

    private func setTitleAndDetails(for asset: OfflineAsset) {
        title.text = asset.title
        details.text = "\(TimeUtils.formatDate(date: asset.createdAt)) • \(TimeUtils.formatDuration(seconds: asset.duration)) • \(String(format: "%.2f MB", asset.size / 8 / 1024 / 1024))"
    }

    private func configureProgress(for asset: OfflineAsset) {
        switch asset.status {
        case Status.inProgress.rawValue:
            let progress = asset.percentageCompleted / 100
            progressView.isHidden = false
            progressView.progress = Float(progress)
            cancelButton.isHidden = false
        case Status.finished.rawValue:
            progressView.isHidden = true
            cancelButton.isHidden = true
        default:
            break
        }
    }

    private func setUpGestures(for asset: OfflineAsset) {
        containerCell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onItemClick)))
        
        cancelButton.addTapGestureRecognizer {
            TPStreamsDownloadManager.shared.cancelDownload(asset.assetId)
        }
    }
    
    @objc func onItemClick() {
        delegate?.didTapItem(for: offlineAsset!.assetId)
    }
}

protocol OfflineDownloadTableViewCellDelegate: AnyObject {
    func didTapItem(for assetId: String)
}
