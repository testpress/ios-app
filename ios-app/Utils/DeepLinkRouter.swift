import UIKit

public class DeepLinkRouter {

    public static let shared = DeepLinkRouter()
    private init() {}

    private var pendingURL: URL?
    private var isAppReady = false

    public func route(url: URL) {
        guard isAppReady else {
            pendingURL = url
            return
        }
        routeIfAuthenticated(url)
    }

    public func appDidBecomeReady() {
        isAppReady = true
        processPending()
    }

    private func processPending() {
        guard isAppReady else { return }
        guard let url = pendingURL else { return }
        guard currentRootViewController != nil else { return }
        pendingURL = nil
        routeIfAuthenticated(url)
    }

    private func routeIfAuthenticated(_ url: URL) {
        DispatchQueue.main.async { [weak self] in
            guard let self,
                  let rootVC = self.currentRootViewController else { return }
            self.dismissAllPresented(from: rootVC) {
                self.resetNavigationStacks(from: rootVC)
                NavigationService.shared.navigateIfAuthenticated(url: url, from: rootVC)
            }
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
