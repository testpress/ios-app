import UIKit
import CourseKit

public class DeepLinkRouter {

    public static let shared = DeepLinkRouter()
    private init() {}

    public var pendingURL: URL?

    public func route(url: URL) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let topVC = UIApplication.topViewController() else { return }
            guard let contentID = self.extractContentID(from: url), let id = Int(contentID) else { return }

            if let contentVC = topVC as? ContentDetailPageViewController, contentVC.contentId == id {
                return
            }

            self.showContentDetail(id: id, from: topVC)
        }
    }

    private func extractContentID(from url: URL) -> String? {
        if let range = url.path.range(of: "(?<=/contents/)[0-9]+", options: .regularExpression) {
            return String(url.path[range])
        }
        return nil
    }

    private func showContentDetail(id: Int, from presenter: UIViewController) {
        guard let vc = UIStoryboard(name: Constants.CHAPTER_CONTENT_STORYBOARD, bundle: TestpressCourse.bundle)
            .instantiateViewController(withIdentifier: Constants.CONTENT_DETAIL_PAGE_VIEW_CONTROLLER) as? ContentDetailPageViewController
        else { return }

        vc.contentId = id
        presenter.present(vc, animated: true)
    }
}
