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

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.backgroundColor = .white
        setupTableView()
        emptyLabel.isHidden = !artifacts.isEmpty
        tableView.isHidden = artifacts.isEmpty
    }

    private func setupTableView() {
        tableView.register(ArtifactCell.self, forCellReuseIdentifier: "ArtifactCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 56
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 52, bottom: 0, right: 16)
    }

    private func downloadArtifact(_ artifact: Artifact) {
        guard let downloadUrl = URL(string: artifact.url) else {
            showError("Invalid file URL")
            return
        }

        let fileExtension = downloadUrl.pathExtension
        let fileName: String
        if artifact.name.isEmpty {
            fileName = downloadUrl.lastPathComponent
        } else if !fileExtension.isEmpty {
            fileName = "\(artifact.name).\(fileExtension)"
        } else {
            fileName = artifact.name
        }

        FileDownloadUtility.shared.downloadFile(
            viewController: self,
            from: downloadUrl,
            fileName: fileName,
            completion: { [weak self] fileUrl, error in
                if let error = error {
                    self?.showError(error.localizedDescription)
                }
            }
        )
    }

    private func showLockedAlert() {
        let alert = UIAlertController(
            title: "Resource Locked",
            message: "This resource is locked",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Download Failed",
            message: message,
            preferredStyle: .alert
        )
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
            showLockedAlert()
        }
    }
}

// MARK: - ArtifactCell

private class ArtifactCell: UITableViewCell {

    private let fileIconView = UIImageView()
    private let titleLabel = UILabel()
    private let rightIconView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        backgroundColor = .white
        contentView.backgroundColor = .white
        selectionStyle = .none

        fileIconView.translatesAutoresizingMaskIntoConstraints = false
        fileIconView.tintColor = .systemGray
        fileIconView.contentMode = .scaleAspectFit
        contentView.addSubview(fileIconView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.numberOfLines = 2
        contentView.addSubview(titleLabel)

        rightIconView.translatesAutoresizingMaskIntoConstraints = false
        rightIconView.contentMode = .scaleAspectFit
        contentView.addSubview(rightIconView)

        NSLayoutConstraint.activate([
            fileIconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            fileIconView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            fileIconView.widthAnchor.constraint(equalToConstant: 24),
            fileIconView.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.leadingAnchor.constraint(equalTo: fileIconView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            titleLabel.trailingAnchor.constraint(equalTo: rightIconView.leadingAnchor, constant: -8),

            rightIconView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            rightIconView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            rightIconView.widthAnchor.constraint(equalToConstant: 24),
            rightIconView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

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
