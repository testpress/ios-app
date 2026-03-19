import UIKit
import CourseKit

public enum NavigationRoute {
    case post(id: String)
    case content(id: String)
    case login
    case unknown
}

public class NavigationService {

    public static let shared = NavigationService()
    private init() {}

    public func buildURL(from urlString: String) -> URL? {
        if let url = URL(string: urlString),
           let scheme = url.scheme?.lowercased(),
           ["http", "https"].contains(scheme) {
            return url
        }
        guard let base = TestpressCourse.shared.baseURL,
              let baseURL = URL(string: base) else { return nil }
        return URL(string: urlString, relativeTo: baseURL)
    }

    public func parseURL(_ url: URL) -> NavigationRoute {
        let parts = url.pathComponents
        if let id = extractID(after: "p", from: parts) {
            return .post(id: id)
        }
        if let contentID = extractContentID(from: parts) {
            return .content(id: contentID)
        }
        return .unknown
    }

    public func navigateIfAuthenticated(url: URL, from presenter: UIViewController) {
        let route = parseURL(url)
        if case .unknown = route { return }
        if KeychainTokenItem.isExist() {
            navigate(to: route, from: presenter)
        } else {
            navigate(to: .login, from: presenter)
        }
    }

    public func navigate(to route: NavigationRoute, from presenter: UIViewController) {
        switch route {
        case .post(let id):
            presentPostDetail(postID: id, from: presenter)
        case .content(let id):
            presentContentDetail(contentID: id, from: presenter)
        case .login:
            presentLogin(from: presenter)
        case .unknown:
            break
        }
    }

    private func extractID(after keyword: String, from parts: [String]) -> String? {
        guard let index = parts.firstIndex(of: keyword),
              index + 1 < parts.count else { return nil }
        let candidate = parts[index + 1]
        return candidate.isEmpty || candidate == keyword ? nil : candidate
    }

    private func extractContentID(from parts: [String]) -> String? {
        return extractID(after: "chapters", from: parts)
            ?? extractID(after: "contents", from: parts)
    }

    private func presentPostDetail(postID: String, from presenter: UIViewController) {
        guard let baseURL = TestpressCourse.shared.baseURL,
              let vc = instantiateViewController(Constants.POST_STORYBOARD,
                                               Constants.POST_DETAIL_VIEW_CONTROLLER) as? PostDetailViewController
        else { return }

        vc.url = "\(baseURL)/api/v2.2/posts/\(postID)/?short_link=true"
        presenter.present(vc, animated: true)
    }

    private func presentContentDetail(contentID: String, from presenter: UIViewController) {
        guard let baseURL = TestpressCourse.shared.baseURL else { return }
        let loadingView = LoadingView(parentView: presenter.view)
        loadingView.show()

        Content.fetchContent(url: "\(baseURL)/api/v2.4/contents/\(contentID)/") { [weak self, weak presenter] content, error in
            DispatchQueue.main.async { [weak self, weak presenter] in
                loadingView.hide()
                guard let self = self, let presenter = presenter else { return }

                if let error = error {
                    self.showError(error: error, from: presenter)
                } else if let content {
                    self.presentContent(content: content, from: presenter)
                }
            }
        }
    }

    private func presentContent(content: Content, from presenter: UIViewController) {
        guard let vc = instantiateViewController(Constants.CHAPTER_CONTENT_STORYBOARD,
                                                Constants.CONTENT_DETAIL_PAGE_VIEW_CONTROLLER,
                                                bundle: TestpressCourse.bundle) as? ContentDetailPageViewController
        else { return }

        vc.position = 0
        vc.contents = [content]
        presenter.present(vc, animated: true)
    }

    private func presentLogin(from presenter: UIViewController) {
        guard let vc = instantiateViewController(Constants.MAIN_STORYBOARD,
                                                 Constants.LOGIN_VIEW_CONTROLLER) as? LoginViewController
        else { return }

        presenter.present(vc, animated: true)
    }

    private func showError(error: Error, from presenter: UIViewController) {
        let tpError = error as? TPError ?? TPError(message: nil, response: nil, kind: .unexpected)
        let (image, title, description) = tpError.getDisplayInfo()
        let emptyView = EmptyView.getInstance(parentView: presenter.view)
        emptyView.show(image: image, title: title, description: description,
                       retryButtonText: nil, retryHandler: nil)
    }

    private func instantiateViewController(_ storyboard: String, _ identifier: String, bundle: Bundle? = nil) -> UIViewController? {
        UIStoryboard(name: storyboard, bundle: bundle).instantiateViewController(withIdentifier: identifier)
    }

    private class LoadingView {
        private let emptyView: EmptyView
        private let spinner: UIActivityIndicatorView

        init(parentView: UIView) {
            emptyView = EmptyView.getInstance(parentView: parentView)
            emptyView.backgroundColor = .white
            spinner = UIUtils.initActivityIndicator(parentView: parentView)
            spinner.center = CGPoint(x: parentView.center.x, y: parentView.center.y - 50)
        }

        func show() {
            spinner.startAnimating()
        }

        func hide() {
            spinner.stopAnimating()
            emptyView.hide()
        }
    }
}
