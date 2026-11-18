import UIKit
import CourseKit
import SafariServices

public protocol DeepLinkBaseProtocol: AnyObject {
    var deepLinkURL: URL? { get set }
}

public class DeepLinkRouter {

    public static let shared = DeepLinkRouter()
    private init() {}

    public func route(destination: String, animated: Bool = true, on viewController: UIViewController? = nil) {
        let trimmed = destination.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            if let targetVC = targetViewController(from: viewController) {
                navigateToHomepage(animated: animated, on: targetVC)
            }
            return
        }

        if trimmed.lowercased().hasPrefix("http://") || trimmed.lowercased().hasPrefix("https://") {
            if let url = URL(string: trimmed) {
                route(url: url, animated: animated, on: viewController)
            }
            return
        }

        let base = TestpressCourse.shared.baseURL ?? "https://testpress.in"
        let path = trimmed.hasPrefix("/") ? trimmed : "/\(trimmed)"
        if let url = URL(string: "\(base)\(path)") {
            route(url: url, animated: animated, on: viewController)
        }
    }

    public func route(url: URL, animated: Bool = true, on viewController: UIViewController? = nil) {
        guard let topVC = targetViewController(from: viewController) else {
            return
        }

        // 1. Check for external URLs
        if let scheme = url.scheme?.lowercased(), (scheme == "http" || scheme == "https") {
            let host = url.host?.lowercased()
            let instituteHost = URL(string: TestpressCourse.shared.baseURL ?? "")?.host?.lowercased()
            if let host = host {
                if let instituteHost = instituteHost, !instituteHost.isEmpty {
                    if host != instituteHost {
                        openExternal(url: url, animated: animated, on: topVC)
                        return
                    }
                } else {
                    openExternal(url: url, animated: animated, on: topVC)
                    return
                }
            }
        }

        // 2. Parse path segments
        let segments = url.pathComponents.filter { $0 != "/" && !$0.isEmpty }

        // 3. Homepage check: "", "/", "/dashboard", "/dashboard_v1"
        if segments.isEmpty || (segments.count == 1 && (segments[0] == "dashboard" || segments[0] == "dashboard_v1")) {
            navigateToHomepage(animated: animated, on: topVC)
            return
        }

        // 4. Store check: "/products", "/store"
        if segments.count == 1 && (segments[0] == "products" || segments[0] == "store") {
            openStore(animated: animated, on: topVC)
            return
        }

        // 5. Specific Product check: "/products/<slug>"
        if segments.count >= 2 && segments[0] == "products" {
            let slug = segments[1]
            openProduct(slug: slug, animated: animated, on: topVC)
            return
        }

        // 6. Content detail check: "/contents/<id>"
        if let contentID = extractContentID(from: url), let id = Int(contentID) {
            openContent(id: id, animated: animated, on: topVC)
            return
        }

        // 7. Legacy chapter check: "/chapters/<slug>/<id>" or "/chapters/<id>"
        if segments.first == "chapters" {
            let contentIdStr = segments.count >= 3 ? segments[2] : (segments.count >= 2 ? segments[1] : nil)
            if let contentIdStr = contentIdStr, let id = Int(contentIdStr) {
                openContent(id: id, animated: animated, on: topVC)
                return
            }
        }

        // 8. Legacy post check: "/p/<id>"
        if segments.first == "p", segments.count >= 2 {
            let postId = segments[1]
            openPost(id: postId, animated: animated, on: topVC)
            return
        }
    }

    private func targetViewController(from viewController: UIViewController?) -> UIViewController? {
        let candidate = viewController ?? UIApplication.topViewController()
        if let presented = candidate?.presentedViewController {
            return UIApplication.topViewController(controller: presented)
        }
        return candidate
    }

    private func openExternal(url: URL, animated: Bool, on topVC: UIViewController) {
        let safariVC = SFSafariViewController(url: url)
        topVC.present(safariVC, animated: animated, completion: nil)
    }

    private func navigateToHomepage(animated: Bool, on topVC: UIViewController) {
        let rootVC = UIApplication.shared.keyWindow?.rootViewController
        let tabController = (rootVC as? UITabBarController) ?? (topVC as? UITabBarController) ?? topVC.tabBarController

        if let tabController = tabController {
            if tabController.presentedViewController != nil {
                tabController.dismiss(animated: animated, completion: nil)
            }
            tabController.selectedIndex = 0
            if let nav = tabController.selectedViewController as? UINavigationController {
                nav.popToRootViewController(animated: animated)
            }
        }
    }

    private func openStore(animated: Bool, on topVC: UIViewController) {
        if let current = topVC as? WebViewController, current.url == "&next=/products/" {
            return
        }
        let webViewController = WebViewController()
        webViewController.url = "&next=/products/"
        webViewController.useSSOLogin = true
        webViewController.displayNavbar = true
        webViewController.useWebviewNavigation = true
        webViewController.title = "Store"
        webViewController.modalPresentationStyle = .fullScreen
        topVC.present(webViewController, animated: animated, completion: nil)
    }

    private func openProduct(slug: String, animated: Bool, on topVC: UIViewController) {
        let nextURL = "&next=/products/\(slug)/"
        if let current = topVC as? WebViewController, current.url == nextURL {
            return
        }
        let webViewController = WebViewController()
        webViewController.url = nextURL
        webViewController.useSSOLogin = true
        webViewController.displayNavbar = true
        webViewController.useWebviewNavigation = true
        webViewController.title = "Product"
        webViewController.modalPresentationStyle = .fullScreen
        topVC.present(webViewController, animated: animated, completion: nil)
    }

    private func openContent(id: Int, animated: Bool, on topVC: UIViewController) {
        if let current = topVC as? ContentDetailPageViewController, current.contentId == id {
            return
        }

        let storyboard = UIStoryboard(
            name: Constants.CHAPTER_CONTENT_STORYBOARD,
            bundle: TestpressCourse.bundle
        )

        if let vc = storyboard.instantiateViewController(
            withIdentifier: Constants.CONTENT_DETAIL_PAGE_VIEW_CONTROLLER
        ) as? ContentDetailPageViewController {
            vc.contentId = id
            vc.modalPresentationStyle = .overFullScreen
            topVC.present(vc, animated: animated, completion: nil)
        }
    }

    private func openPost(id: String, animated: Bool, on topVC: UIViewController) {
        let storyboard = UIStoryboard(name: Constants.POST_STORYBOARD, bundle: nil)
        if let vc = storyboard.instantiateViewController(
            withIdentifier: Constants.POST_DETAIL_VIEW_CONTROLLER
        ) as? PostDetailViewController {
            let base = TestpressCourse.shared.baseURL ?? ""
            vc.url = "\(base)/api/v2.2/posts/\(id)/?short_link=true"
            topVC.present(vc, animated: animated, completion: nil)
        }
    }

    private func extractContentID(from url: URL) -> String? {
        let string = url.absoluteString
        return string.range(of: "(?<=contents/)[0-9]+", options: .regularExpression).map { String(string[$0]) }
    }
}
