//
//  ArtifactListViewController.swift
//  CourseKit
//
//  Copyright © 2024 Testpress. All rights reserved.
//

import UIKit

class ArtifactListViewController: BaseUIViewController {

    @IBOutlet weak var dragHandleView: UIView!
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var headerSubtitleLabel: UILabel!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!

    var artifacts: [Artifact] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.backgroundColor = .white
        setupTableView()
        emptyLabel.isHidden = !artifacts.isEmpty
        tableView.isHidden = artifacts.isEmpty
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 56
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 52, bottom: 0, right: 16)
    }

    private func downloadArtifact(_ artifact: Artifact) {
        guard let downloadUrl = URL(string: artifact.url) else {
            showAlert(title: "Download Failed", message: "Invalid file URL")
            return
        }

        let baseName = artifact.name.isEmpty ? downloadUrl.lastPathComponent : artifact.name
        let ext = downloadUrl.pathExtension
        let fileName = ext.isEmpty ? baseName : "\(baseName).\(ext)"

        FileDownloadUtility.shared.downloadFile(
            viewController: self,
            from: downloadUrl,
            fileName: fileName,
            completion: { [weak self] fileUrl, error in
                if let error = error {
                    self?.showAlert(title: "Download Failed", message: error.localizedDescription)
                }
            }
        )
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension ArtifactListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artifacts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArtifactCell", for: indexPath) as! ArtifactCell
        let artifact = artifacts[indexPath.row]
        cell.configure(with: artifact)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let artifact = artifacts[indexPath.row]
        if artifact.accessibleWithoutAttempt {
            downloadArtifact(artifact)
        } else {
            showAlert(title: "Resource Locked", message: "This resource is locked")
        }
    }
}

// MARK: - ArtifactCell

class ArtifactCell: UITableViewCell {
    @IBOutlet weak var fileIconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rightIconView: UIImageView!

    func configure(with artifact: Artifact) {
        titleLabel.text = artifact.name.isEmpty ? artifact.url : artifact.name
        let isPDF = artifact.url.lowercased().hasSuffix(".pdf")
        fileIconView.image = UIImage(systemName: isPDF ? "doc.text" : "doc")

        if artifact.accessibleWithoutAttempt {
            alpha = 1.0
            rightIconView.image = UIImage(systemName: "arrow.down.circle")
            rightIconView.tintColor = TestpressCourse.shared.primaryColor
        } else {
            alpha = 0.5
            rightIconView.image = UIImage(systemName: "lock")
            rightIconView.tintColor = .systemGray
        }
    }
}
