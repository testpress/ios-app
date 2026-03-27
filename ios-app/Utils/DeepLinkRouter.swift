import UIKit
import CourseKit

public class DeepLinkRouter {

    public static let shared = DeepLinkRouter()
    private init() {}
    

    public func route( url: URL, animated: Bool = true, on viewController: UIViewController? = nil ) {
        if url.absoluteString.contains("contents/"),
           let contentID = extractContentID(from: url),
           let id = Int(contentID) {
            
            if let topVC = viewController ?? UIApplication.topViewController() {
                if let current = topVC as? ContentDetailPageViewController,
                   current.contentId == id {
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
        } else {
            return
        }
    }

    private func extractContentID(from url: URL) -> String? {
        let string = url.absoluteString
        return string.range(of: "(?<=contents/)[0-9]+", options: .regularExpression).map { String(string[$0]) }
    }
}
