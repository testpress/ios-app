import UIKit

#if SWIFT_PACKAGE
let bundle = Bundle.module
#else
let bundle = Bundle(for: TestpressCourse.self)
#endif

public class TestpressCourse {
    public static let shared = TestpressCourse()

    private init() {}

    public func getMyCoursesViewController() -> CourseListViewController? {
        return instantiateViewController(withIdentifier: "CourseListViewController")
    }

    public func getContentDetailViewController(contentId: Int) -> ContentDetailViewController? {
        let contentDetailVC: ContentDetailViewController? = instantiateViewController(withIdentifier: "ContentDetailViewController")
        contentDetailVC?.contentId = contentId
        contentDetailVC?.modalPresentationStyle = .fullScreen
        return contentDetailVC
    }

    private func instantiateViewController<T>(withIdentifier identifier: String) -> T? {
        let storyboard = UIStoryboard(name: "Course", bundle: bundle)
        return storyboard.instantiateViewController(withIdentifier: identifier) as? T
    }
}
