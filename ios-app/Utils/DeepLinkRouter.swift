import UIKit
import CourseKit

public class DeepLinkRouter {

    public static let shared = DeepLinkRouter()
    private init() {}

    public func route(url: URL, animated: Bool = true, on viewController: UIViewController? = nil) {
        guard let contentID = extractContentID(from: url), let id = Int(contentID) else { return }
        
        let targetVC = viewController ?? UIApplication.topViewController()
        guard let topVC = targetVC else { return }

        if let current = topVC as? ContentDetailPageViewController, current.contentId == id {
            return
        }

        let storyboard = UIStoryboard(name: Constants.CHAPTER_CONTENT_STORYBOARD, bundle: TestpressCourse.bundle)
        guard let vc = storyboard.instantiateViewController(withIdentifier: Constants.CONTENT_DETAIL_PAGE_VIEW_CONTROLLER) as? ContentDetailPageViewController else {
            return
        }

        vc.contentId = id
        topVC.present(vc, animated: animated)
    }

    private func extractContentID(from url: URL) -> String? {
        return url.path.range(of: "(?<=/contents/)[0-9]+", options: .regularExpression).map { String(url.path[$0]) }
    }
}
