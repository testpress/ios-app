import UIKit
import CourseKit

public enum DeepLinkDestination {
    case post(id: String)
    case content(id: String)
    case login
    case unknown
}

public class NavigationService {

    public static let shared = NavigationService()
    private init() {}

    public func parseDeepLink(_ url: URL) -> DeepLinkDestination {
        let pathParts = url.pathComponents
        if let postID = extractID(after: "p", from: pathParts) {
            return .post(id: postID)
        }
        if let contentID = extractContentID(from: pathParts) {
            return .content(id: contentID)
        }
        return .unknown
    }

    public func navigateToDeepLink(url: URL, from presenter: UIViewController) {
        let destination = parseDeepLink(url)
        if case .unknown = destination { return }

        if !KeychainTokenItem.isExist() {
            showLoginScreen(from: presenter)
            return
        }

        switch destination {
        case .post(let id):
            showPostDetail(id: id, from: presenter)
        case .content(let id):
            showContentDetail(id: id, from: presenter)
        case .login, .unknown:
            break
        }
    }

    private func extractID(after keyword: String, from parts: [String]) -> String? {
        guard let index = parts.firstIndex(of: keyword),
              index + 1 < parts.count else { return nil }
        let candidate = parts[index + 1]
        return candidate.isEmpty ? nil : candidate
    }

    private func extractContentID(from parts: [String]) -> String? {
        return extractID(after: "chapters", from: parts)
            ?? extractID(after: "contents", from: parts)
    }

    private func showPostDetail(id: String, from presenter: UIViewController) {
        guard let baseURL = TestpressCourse.shared.baseURL else {
            debugPrint("[NavigationService] Cannot show post - baseURL not configured")
            return
        }
        guard let vc = instantiateVC(Constants.POST_STORYBOARD, Constants.POST_DETAIL_VIEW_CONTROLLER) as? PostDetailViewController
        else { return }

        vc.url = "\(baseURL)/api/v2.2/posts/\(id)/?short_link=true"
        presenter.present(vc, animated: true)
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
        guard let vc = instantiateVC(Constants.CHAPTER_CONTENT_STORYBOARD,
                                     Constants.CONTENT_DETAIL_PAGE_VIEW_CONTROLLER,
                                     bundle: TestpressCourse.bundle) as? ContentDetailPageViewController
        else { return }

        vc.position = 0
        vc.contents = [content]
        presenter.present(vc, animated: true)
    }

    private func showLoginScreen(from presenter: UIViewController) {
        guard let vc = instantiateVC(Constants.MAIN_STORYBOARD, Constants.LOGIN_VIEW_CONTROLLER) as? LoginViewController
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

    private func instantiateVC(_ storyboard: String, _ identifier: String, bundle: Bundle? = nil) -> UIViewController? {
        UIStoryboard(name: storyboard, bundle: bundle).instantiateViewController(withIdentifier: identifier)
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
