import UIKit
import CourseKit

public class NavigationService {

    public static let shared = NavigationService()
    private init() {}

    public func navigateToDeepLink(url: URL, from presenter: UIViewController) {
        guard let contentID = extractContentID(from: url.pathComponents) else { return }

        if !KeychainTokenItem.isExist() {
            showLoginScreen(from: presenter)
            return
        }

        showContentDetail(id: contentID, from: presenter)
    }

    private func extractContentID(from parts: [String]) -> String? {
        guard let index = parts.firstIndex(of: "contents"),
              index + 1 < parts.count else { return nil }
        let id = parts[index + 1]
        return id.isEmpty ? nil : id
    }

    private func showContentDetail(id: String, from presenter: UIViewController) {
        guard let baseURL = TestpressCourse.shared.baseURL else {
            debugPrint("[NavigationService] Cannot show content - baseURL not configured")
            return
        }
        let loadingOverlay = LoadingOverlay(parentView: presenter.view)
        loadingOverlay.show()

        Content.fetchContent(url: "\(baseURL)/api/v2.4/contents/\(id)/") { [weak self, weak presenter] content, error in
            DispatchQueue.main.async { [weak self, weak presenter] in
                loadingOverlay.hide()
                guard let self = self, let presenter = presenter else { return }

                if let error = error {
                    self.showErrorOverlay(error: error, from: presenter)
                } else if let content {
                    self.displayContentDetail(content, from: presenter)
                }
            }
        }
    }

    private func displayContentDetail(_ content: Content, from presenter: UIViewController) {
        guard let vc = UIStoryboard(name: Constants.CHAPTER_CONTENT_STORYBOARD, bundle: TestpressCourse.bundle)
            .instantiateViewController(withIdentifier: Constants.CONTENT_DETAIL_PAGE_VIEW_CONTROLLER) as? ContentDetailPageViewController
        else { return }

        vc.position = 0
        vc.contents = [content]
        presenter.present(vc, animated: true)
    }

    private func showLoginScreen(from presenter: UIViewController) {
        guard let vc = UIStoryboard(name: Constants.MAIN_STORYBOARD, bundle: nil)
            .instantiateViewController(withIdentifier: Constants.LOGIN_VIEW_CONTROLLER) as? LoginViewController
        else { return }

        presenter.present(vc, animated: true)
    }

    private func showErrorOverlay(error: Error, from presenter: UIViewController) {
        let tpError = error as? TPError ?? TPError(message: nil, response: nil, kind: .unexpected)
        let (image, title, description) = tpError.getDisplayInfo()

        let emptyView = EmptyView.getInstance(parentView: presenter.view)

        if tpError.kind == .network {
            emptyView.show(image: image, title: title, description: description,
                           retryButtonText: Strings.TRY_AGAIN,
                           retryHandler: { emptyView.hide() })
        } else {
            emptyView.show(image: image, title: title, description: description,
                           retryButtonText: "Go Back") { [weak presenter] in
                emptyView.hide()
                presenter?.dismiss(animated: true)
            }
        }
    }

    private class LoadingOverlay {
        private let parentView: UIView
        private let overlay = UIView()
        private let spinner: UIActivityIndicatorView

        init(parentView: UIView) {
            self.parentView = parentView
            overlay.frame = parentView.bounds
            overlay.backgroundColor = .white
            overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            spinner = UIUtils.initActivityIndicator(parentView: overlay)
            spinner.center = CGPoint(x: parentView.center.x, y: parentView.center.y - 50)
        }

        func show() {
            parentView.addSubview(overlay)
            spinner.startAnimating()
        }

        func hide() {
            spinner.stopAnimating()
            overlay.removeFromSuperview()
        }
    }
}
