import UIKit
import CourseKit

private enum DeepLinkRoute {
    case post(id: String)
    case content(id: String)
    case unknown
}

public class DeepLinkRouter {

    public static let shared = DeepLinkRouter()
    private init() {}

    private var pendingURL: URL?
    private var isAppReady = false

    public func setAppReady() {
        isAppReady = true
        if let url = pendingURL {
            pendingURL = nil
            navigateToURL(url)
        }
    }

    public func route(url: URL) {
        guard isAppReady else {
            pendingURL = url
            return
        }
        navigateToURL(url)
    }

    public func routeFromNotification(userInfo: [AnyHashable: Any]) {
        guard let urlString = userInfo["short_url"] as? String,
              let url = resolvedURL(from: urlString)
        else { return }

        guard isAppReady else {
            pendingURL = url
            return
        }
        navigateToURL(url)
    }

    private func navigateToURL(_ url: URL) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let presenter = UIApplication.topViewController() ?? UIApplication.shared.keyWindow?.rootViewController
            guard let presenter else { return }

            if KeychainTokenItem.isExist() {
                self.decideAndNavigate(for: url, from: presenter)
            } else {
                self.navigateToLogin(from: presenter)
            }
        }
    }

    private func decideAndNavigate(for url: URL, from presenter: UIViewController) {
        switch resolvedRoute(from: url) {
        case .post(let id):
            navigateToPost(postID: id, from: presenter)
        case .content(let id):
            navigateToContent(contentID: id, from: presenter)
        case .unknown:
            break
        }
    }

    private func resolvedRoute(from url: URL) -> DeepLinkRoute {
        let parts = url.pathComponents
        if let id = extractID(after: "p", in: parts) { return .post(id: id) }

        if parts.contains("chapters") && parts.count >= 4 {
            let contentID = parts[parts.count - 1]
            if !contentID.isEmpty && contentID != "chapters" {
                return .content(id: contentID)
            }
        }

        if let id = extractID(after: "contents", in: parts) { return .content(id: id) }
        return .unknown
    }

    private func navigateToPost(postID: String, from presenter: UIViewController) {
        guard let baseURL = TestpressCourse.shared.baseURL,
              let vc = instantiateViewController(Constants.POST_STORYBOARD,
                                                 Constants.POST_DETAIL_VIEW_CONTROLLER) as? PostDetailViewController
        else { return }

        vc.url = "\(baseURL)/api/v2.2/posts/\(postID)/?short_link=true"
        presenter.present(vc, animated: true)
    }

    private func navigateToContent(contentID: String, from presenter: UIViewController) {
        guard let baseURL = TestpressCourse.shared.baseURL else { return }

        let emptyView = EmptyView.getInstance(parentView: presenter.view)
        emptyView.backgroundColor = .white
        let spinner = UIUtils.initActivityIndicator(parentView: presenter.view)
        spinner.center = CGPoint(x: presenter.view.center.x, y: presenter.view.center.y - 50)
        spinner.startAnimating()

        Content.fetchContent(url: "\(baseURL)/api/v2.4/contents/\(contentID)/") { [weak self, weak presenter] content, error in
            guard let self = self else { return }
            spinner.stopAnimating()
            guard let presenter else { return }

            if let error = error {
                let (image, title, description) = error.getDisplayInfo()
                emptyView.show(image: image, title: title, description: description,
                              retryButtonText: Strings.TRY_AGAIN, retryHandler: { emptyView.hide() })
            } else if let content {
                guard let vc = self.instantiateViewController(
                    Constants.CHAPTER_CONTENT_STORYBOARD,
                    Constants.CONTENT_DETAIL_PAGE_VIEW_CONTROLLER,
                    bundle: TestpressCourse.bundle
                ) as? ContentDetailPageViewController else { return }

                vc.position = 0
                vc.contents = [content]
                presenter.present(vc, animated: true)
            }
        }
    }

    private func navigateToLogin(from presenter: UIViewController) {
        guard let vc = instantiateViewController(Constants.MAIN_STORYBOARD,
                                                 Constants.LOGIN_VIEW_CONTROLLER) as? LoginViewController
        else { return }

        presenter.present(vc, animated: true)
    }

    private func extractID(after keyword: String, in parts: [String]) -> String? {
        guard let index = parts.firstIndex(of: keyword), index + 1 < parts.count else { return nil }
        let candidate = parts[index + 1]
        return candidate.isEmpty || candidate == keyword ? nil : candidate
    }

    private func resolvedURL(from urlString: String) -> URL? {
        if urlString.hasPrefix("http") || urlString.hasPrefix("https") { return URL(string: urlString) }
        if urlString.contains("://") { return URL(string: urlString) }
        guard let baseURLString = TestpressCourse.shared.baseURL,
              let baseURL = URL(string: baseURLString)
        else { return nil }
        return URL(string: urlString, relativeTo: baseURL)
    }

    private func instantiateViewController(_ storyboard: String, _ identifier: String, bundle: Bundle? = nil) -> UIViewController? {
        UIStoryboard(name: storyboard, bundle: bundle).instantiateViewController(withIdentifier: identifier)
    }
}
