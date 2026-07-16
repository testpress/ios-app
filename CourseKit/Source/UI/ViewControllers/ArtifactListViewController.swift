//
//  ArtifactListViewController.swift
//  CourseKit
//
//  Copyright © 2024 Testpress. All rights reserved.
//

import UIKit

class ArtifactListViewController: UIViewController {

    private let tableView = UITableView()
    private let emptyLabel = UILabel()

    // Bottom sheet header views
    private let dragHandleView = UIView()
    private let headerTitleLabel = UILabel()
    private let headerSubtitleLabel = UILabel()
    private let dividerView = UIView()

    private var artifacts: [Artifact]

    init(artifacts: [Artifact]) {
        self.artifacts = artifacts
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupHeader()
        setupTableView()
        setupEmptyLabel()
    }

    private func setupHeader() {
        // Drag handle
        dragHandleView.translatesAutoresizingMaskIntoConstraints = false
        dragHandleView.backgroundColor = .systemGray4
        dragHandleView.layer.cornerRadius = 2.5
        dragHandleView.clipsToBounds = true
        view.addSubview(dragHandleView)

        // Title
        headerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerTitleLabel.text = "Resources"
        headerTitleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        headerTitleLabel.textColor = .black
        view.addSubview(headerTitleLabel)

        // Subtitle
        headerSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerSubtitleLabel.text = "Access your study materials"
        headerSubtitleLabel.font = UIFont.systemFont(ofSize: 14)
        headerSubtitleLabel.textColor = .systemGray
        view.addSubview(headerSubtitleLabel)

        // Divider
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        dividerView.backgroundColor = .systemGray5
        view.addSubview(dividerView)

        NSLayoutConstraint.activate([
            dragHandleView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            dragHandleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dragHandleView.widthAnchor.constraint(equalToConstant: 40),
            dragHandleView.heightAnchor.constraint(equalToConstant: 5),

            headerTitleLabel.topAnchor.constraint(equalTo: dragHandleView.bottomAnchor, constant: 16),
            headerTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            headerSubtitleLabel.topAnchor.constraint(equalTo: headerTitleLabel.bottomAnchor, constant: 4),
            headerSubtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerSubtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            dividerView.topAnchor.constraint(equalTo: headerSubtitleLabel.bottomAnchor, constant: 12),
            dividerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dividerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dividerView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ArtifactCell.self, forCellReuseIdentifier: "ArtifactCell")
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 52, bottom: 0, right: 16)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: dividerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupEmptyLabel() {
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.text = "No resources available"
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .systemGray
        emptyLabel.font = UIFont.systemFont(ofSize: 16)
        emptyLabel.isHidden = !artifacts.isEmpty
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func downloadArtifact(_ artifact: Artifact) {
        guard let downloadUrl = URL(string: artifact.url) else {
            showError("Invalid file URL")
            return
        }

        let fileName = artifact.name.isEmpty ? downloadUrl.lastPathComponent : "\(artifact.name).pdf"

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
            fileIconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            fileIconView.widthAnchor.constraint(equalToConstant: 24),
            fileIconView.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.leadingAnchor.constraint(equalTo: fileIconView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: rightIconView.leadingAnchor, constant: -8),

            rightIconView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            rightIconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
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
