import UIKit
import CourseKit

public class DeepLinkRouter {

    public static let shared = DeepLinkRouter()
    private init() {}

    private var pendingURL: URL?

    public func handleIncomingURL(_ url: URL) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let rootVC = self.currentRootViewController, !(rootVC is MainViewController) {
                self.navigateToDeepLink(url: url)
            } else {
                self.pendingURL = url
            }
        }
    }

    public func setPendingURL(_ url: URL) {
        pendingURL = url
    }

    public static func extractURLFromLaunchOptions(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> URL? {
        guard let userActivityDict = launchOptions?[.userActivityDictionary] as? [String: Any],
              let userActivity = userActivityDict["UIApplicationLaunchOptionsUserActivityKey"] as? NSUserActivity
        else { return nil }
        return userActivity.webpageURL
    }


    public func flushPendingDeepLink() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let rootVC = self.currentRootViewController,
                  !(rootVC is MainViewController),
                  let url = self.pendingURL else { return }

            self.pendingURL = nil
            self.navigateToDeepLink(url: url)
        }
    }

    private func navigateToDeepLink(url: URL) {
        guard let rootVC = currentRootViewController else { return }
        dismissPresentedViewControllers(from: rootVC) { [weak self] in
            self?.resetNavigationToRoot(from: rootVC)
            rootVC.view.subviews.filter { $0 is EmptyView }.forEach { $0.removeFromSuperview() }
            self?.presentContentForURL(url, from: rootVC)
        }
    }

    private func resetNavigationToRoot(from rootVC: UIViewController) {
        if let tabBar = rootVC as? UITabBarController {
            tabBar.viewControllers?
                .compactMap { $0 as? UINavigationController }
                .forEach { $0.popToRootViewController(animated: false) }
        } else if let nav = rootVC as? UINavigationController {
            nav.popToRootViewController(animated: false)
        }
    }

    private func dismissPresentedViewControllers(from viewController: UIViewController, completion: @escaping () -> Void) {
        if let presented = viewController.presentedViewController {
            presented.dismiss(animated: false) { [weak self] in
                self?.dismissPresentedViewControllers(from: viewController, completion: completion)
            }
        } else {
            completion()
        }
    }

    private var currentRootViewController: UIViewController? {
        (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController
    }

    // MARK: - Content Presentation

    private func presentContentForURL(_ url: URL, from presenter: UIViewController) {
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
            debugPrint("[DeepLinkRouter] Cannot show content - baseURL not configured")
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
