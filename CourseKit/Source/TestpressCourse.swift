import UIKit

public class TestpressCourse {
    public static let shared = TestpressCourse()

    private init() {}

    public func showMyCourses(from context: UIViewController) {
        let storyboard = UIStoryboard(name: "Course", bundle: Bundle(for: TestpressCourse.self))
        if let viewController = storyboard.instantiateViewController(withIdentifier: identifier) as? CourseListViewController {
            return viewController
        } else {
            return nil
        }
        presentViewController(viewController, from: context)
    }

    public func showContentDetail(from context: UIViewController, contentId: Int) {
        let contentDetailVC: ContentDetailViewController? = instantiateViewController(withIdentifier: "ContentDetailViewController")
        contentDetailVC?.contentId = contentId
        contentDetailVC?.modalPresentationStyle = .fullScreen
        presentViewController(contentDetailVC, from: context)
    }
    
    private func instantiateViewController<T>(withIdentifier identifier: String) -> CourseListViewController? {
        print("=========================instatitate start============")
        print(identifier)
        let storyboard = UIStoryboard(name: "Course", bundle: Bundle(for: TestpressCourse.self))
        print(storyboard)
        print("=========================instatitate end============")
        print(storyboard.instantiateViewController(withIdentifier: identifier))
        if let viewController = storyboard.instantiateViewController(withIdentifier: identifier) as? CourseListViewController {
            return viewController
        } else {
            print("Error: Could not instantiate view controller with identifier \(identifier)")
            return nil
        }
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
