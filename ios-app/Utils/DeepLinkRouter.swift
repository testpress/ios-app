import UIKit
import CourseKit
import SafariServices

public protocol DeepLinkBaseProtocol: AnyObject {
    var deepLinkURL: URL? { get set }
}

public class DeepLinkRouter {

    public static let shared = DeepLinkRouter()
    private init() {}

    public var pendingDestination: String?

    public func routePendingDestination(on viewController: UIViewController? = nil) {
        guard let dest = pendingDestination, !dest.isEmpty else { return }
        pendingDestination = nil
        route(destination: dest, on: viewController)
    }

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

        guard let base = TestpressCourse.shared.baseURL, !base.isEmpty else {
            return
        }
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
        if let id = extractContentID(from: segments) {
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

    private func getKeyWindow() -> UIWindow? {
        if #available(iOS 13.0, *) {
            for scene in UIApplication.shared.connectedScenes {
                if let windowScene = scene as? UIWindowScene,
                   windowScene.activationState == .foregroundActive || windowScene.activationState == .foregroundInactive {
                    if let keyWin = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first {
                        return keyWin
                    }
                }
            }
        }
        return UIApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? UIApplication.shared.keyWindow
    }

    private func navigateToHomepage(animated: Bool, on topVC: UIViewController) {
        let rootVC = getKeyWindow()?.rootViewController
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

    private func isAlreadyPresenting(url: String, from topVC: UIViewController) -> Bool {
        if let current = topVC as? WebViewController, current.url == url {
            return true
        }
        if let presented = topVC.presentedViewController as? WebViewController, presented.url == url {
            return true
        }
        if let nav = topVC.navigationController {
            return nav.viewControllers.contains { ($0 as? WebViewController)?.url == url }
        }
        return false
    }

    private func openStore(animated: Bool, on topVC: UIViewController) {
        let storeURL = "&next=/products/"
        if isAlreadyPresenting(url: storeURL, from: topVC) {
            return
        }
        let webViewController = WebViewController()
        webViewController.url = storeURL
        webViewController.useSSOLogin = true
        webViewController.displayNavbar = true
        webViewController.useWebviewNavigation = true
        webViewController.title = NSLocalizedString("Store", comment: "Store")
        webViewController.modalPresentationStyle = .fullScreen
        topVC.present(webViewController, animated: animated, completion: nil)
    }

    private func openProduct(slug: String, animated: Bool, on topVC: UIViewController) {
        let nextURL = "&next=/products/\(slug)/"
        if isAlreadyPresenting(url: nextURL, from: topVC) {
            return
        }
        let webViewController = WebViewController()
        webViewController.url = nextURL
        webViewController.useSSOLogin = true
        webViewController.displayNavbar = true
        webViewController.useWebviewNavigation = true
        webViewController.title = NSLocalizedString("Product", comment: "Product")
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

    private func extractContentID(from segments: [String]) -> Int? {
        guard let index = segments.firstIndex(of: "contents"), index + 1 < segments.count else {
            return nil
        }
        return Int(segments[index + 1])
    }
}
