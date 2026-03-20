import UIKit

// Single pendingURL slot: deep links are rare; the latest one overwrites any stale one.
// Intentional tradeoff: simplicity over queueing multiple links.
public class DeepLinkRouter {

    public static let shared = DeepLinkRouter()
    private init() {}

    private var pendingURL: URL?

    public func route(url: URL) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.isAppReady {
                self.dispatch(url: url)
            } else {
                self.pendingURL = url
            }
        }
    }

    private var isAppReady: Bool {
        (UIApplication.shared.delegate as? AppDelegate)?.isAppReady ?? false
    }

    public func processPending() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  self.isAppReady,
                  let url = self.pendingURL,
                  let rootVC = self.currentRootViewController else { return }

            self.pendingURL = nil
            self.dispatch(url: url)
        }
    }

    public func dispatch(url: URL) {
        guard let rootVC = currentRootViewController else { return }
        dismissAllPresented(from: rootVC) { [weak self] in
            self?.resetNavigationStacks(from: rootVC)
            NavigationService.shared.open(url: url, from: rootVC)
        }
    }

    private func resetNavigationStacks(from rootVC: UIViewController) {
        if let tabBar = rootVC as? UITabBarController {
            tabBar.viewControllers?
                .compactMap { $0 as? UINavigationController }
                .forEach { $0.popToRootViewController(animated: false) }
        } else if let nav = rootVC as? UINavigationController {
            nav.popToRootViewController(animated: false)
        }
    }

    private func dismissAllPresented(from viewController: UIViewController, completion: @escaping () -> Void) {
        if let presented = viewController.presentedViewController {
            presented.dismiss(animated: false) { [weak self] in
                self?.dismissAllPresented(from: viewController, completion: completion)
            }
        } else {
            completion()
        }
    }

    private var currentRootViewController: UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
    }
}
