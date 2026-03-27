import UIKit
import CourseKit

public class DeepLinkRouter {

    public static let shared = DeepLinkRouter()
    public private(set) var pendingURL: URL?
    private init() {}
    
    public func setPendingURL(_ url: URL) {
        pendingURL = url
    }
    
    public func routePending(on vc: UIViewController) {
        guard let url = pendingURL else { return }
        pendingURL = nil
        route(url: url, animated: true, on: vc)
    }

    public func route( url: URL, animated: Bool = true, on viewController: UIViewController? = nil, completion: (() -> Void)? = nil ) {
        guard let topVC = viewController ?? UIApplication.topViewController() else {
            return
        }
    
        if let contentID = extractContentID(from: url), let id = Int(contentID) {
            if let current = topVC as? ContentDetailPageViewController,
               current.contentId == id {
                return
            }
    
            let storyboard = UIStoryboard(
                name: Constants.CHAPTER_CONTENT_STORYBOARD,
                bundle: TestpressCourse.bundle
            )
    
            guard let vc = storyboard.instantiateViewController(
                withIdentifier: Constants.CONTENT_DETAIL_PAGE_VIEW_CONTROLLER
            ) as? ContentDetailPageViewController else {
                return
            }
    
            vc.contentId = id
            vc.modalPresentationStyle = .overFullScreen
            topVC.present(vc, animated: animated, completion: completion)
    
            return
        }
    
        completion?()
    }

    private func extractContentID(from url: URL) -> String? {
        return url.path.range(of: "(?<=/contents/)[0-9]+", options: .regularExpression).map { String(url.path[$0]) }
    }
}
