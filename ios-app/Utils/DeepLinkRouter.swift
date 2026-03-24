import UIKit
import CourseKit

public class DeepLinkRouter {

    public static let shared = DeepLinkRouter()
    private init() {}

    public func route(url: URL) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let topVC = UIApplication.topViewController() else { return }
            
            guard let vc = self.getViewController(for: url) as? ContentDetailPageViewController else { return }

            if let contentVC = topVC as? ContentDetailPageViewController, contentVC.contentId == vc.contentId {
                return
            }

            topVC.present(vc, animated: true)
        }
    }

    public func getViewController(for url: URL) -> UIViewController? {
        guard let contentID = extractContentID(from: url), let id = Int(contentID) else { return nil }
        
        guard let vc = UIStoryboard(name: Constants.CHAPTER_CONTENT_STORYBOARD, bundle: TestpressCourse.bundle)
            .instantiateViewController(withIdentifier: Constants.CONTENT_DETAIL_PAGE_VIEW_CONTROLLER) as? ContentDetailPageViewController
        else { return nil }
        
        vc.contentId = id
        return vc
    }

    private func extractContentID(from url: URL) -> String? {
        return url.path.range(of: "(?<=/contents/)[0-9]+", options: .regularExpression).map { String(url.path[$0]) }
    }
}
