import UIKit

public class TestpressCourse {
    public static let shared = TestpressCourse()

    private init() {}

    public func showMyCourses(from context: UIViewController) {
        let storyboard = UIStoryboard(name: "Course", bundle: Bundle(for: TestpressCourse.self))
        guard let courseListVC = storyboard.instantiateViewController(withIdentifier: "CourseListViewController") as? CourseListViewController else {
            return
        }
        
        if let navController = context.navigationController {
            navController.pushViewController(courseListVC, animated: true)
        } else {
            context.present(courseListVC, animated: true, completion: nil)
        }
    }

    public func showContentDetail(from context: UIViewController, contentId: Int) {
        let storyboard = UIStoryboard(name: "Course", bundle: Bundle(for: TestpressCourse.self))
        guard let contentDetailVC = storyboard.instantiateViewController(withIdentifier: "ContentDetailViewController") as? ContentDetailViewController else {
            return
        }
        contentDetailVC.contentId = contentId
        contentDetailVC.modalPresentationStyle = .fullScreen
        if let navController = context.navigationController {
            navController.pushViewController(contentDetailVC, animated: true)
        } else {
            context.present(contentDetailVC, animated: true, completion: nil)
        }
    }
}
