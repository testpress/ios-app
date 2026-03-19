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
            guard let self = self else { return }
            guard let presenter = self.currentRootViewController else { return }
            self.dismissAllPresented(from: presenter) {
                NavigationService.shared.navigateIfAuthenticated(url: url, from: presenter)
            }
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
