import UIKit

// Single pendingURL slot: deep links are rare; the latest one overwrites any stale one.
public class DeepLinkRouter {

    public static let shared = DeepLinkRouter()
    private init() {}

    private var pendingURL: URL?

    @discardableResult
    public func handleIncomingURL(_ url: URL) -> Bool {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.isAppReady {
                self.navigateToDeepLink(url: url)
            } else {
                self.pendingURL = url
            }
        }
        return true
    }

    public func setPendingURL(_ url: URL) {
        pendingURL = url
    }

    // Extract URL from cold start launch options
    public static func extractURLFromLaunchOptions(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> URL? {
        guard let userActivityDict = launchOptions?[.userActivityDictionary] as? [String: Any],
              let userActivity = userActivityDict["UIApplicationLaunchOptionsUserActivityKey"] as? NSUserActivity
        else { return nil }
        return userActivity.webpageURL
    }

    private var isAppReady: Bool {
        (UIApplication.shared.delegate as? AppDelegate)?.isAppReady ?? false
    }

    public func flushPendingDeepLink() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  self.isAppReady,
                  let url = self.pendingURL,
                  self.currentRootViewController != nil else { return }

            self.pendingURL = nil
            self.navigateToDeepLink(url: url)
        }
    }

    private func navigateToDeepLink(url: URL) {
        guard let rootVC = currentRootViewController else { return }
        dismissPresentedViewControllers(from: rootVC) { [weak self] in
            self?.resetNavigationToRoot(from: rootVC)
            NavigationService.shared.navigateToDeepLink(url: url, from: rootVC)
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
}
