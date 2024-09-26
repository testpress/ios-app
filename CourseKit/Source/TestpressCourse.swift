import UIKit

public class TestpressCourse {
    public static let shared = TestpressCourse()

    private init() {}

    public func showMyCourses(from context: UIViewController) {
        print("CALLED")
        let courseListVC: CourseListViewController? = instantiateViewController(withIdentifier: "CourseListViewController")
        print(courseListVC)
        print("couurselistvc called")
        presentViewController(courseListVC, from: context)
        print("presented")
    }

    public func showContentDetail(from context: UIViewController, contentId: Int) {
        let contentDetailVC: ContentDetailViewController? = instantiateViewController(withIdentifier: "ContentDetailViewController")
        contentDetailVC?.contentId = contentId
        contentDetailVC?.modalPresentationStyle = .fullScreen
        presentViewController(contentDetailVC, from: context)
    }
    
    private func instantiateViewController<T>(withIdentifier identifier: String) -> T? {
        let storyboard = UIStoryboard(name: "Course", bundle: Bundle(for: TestpressCourse.self))
        return storyboard.instantiateViewController(withIdentifier: identifier) as? T
    }

    private func presentViewController(_ viewController: UIViewController?, from context: UIViewController) {
        guard let viewController = viewController else { return }
        if let navController = context.navigationController {
            navController.pushViewController(viewController, animated: true)
        } else {
            context.present(viewController, animated: true, completion: nil)
        }
    }
}
