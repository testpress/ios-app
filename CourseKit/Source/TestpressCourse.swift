import UIKit

public class TestpressCourse {
    public static let shared = TestpressCourse()

    private init() {}

    public func showMyCourses(from context: UIViewController) {
        print("CALLED")
        // Instantiate the storyboard using the name and bundle.
        let storyboard = UIStoryboard(name: "Course", bundle: Bundle(for: CourseListViewController.self))

        // Safely unwrap the instantiated view controller.
        if let viewController = storyboard.instantiateViewController(withIdentifier: "CourseListViewController") as? CourseListViewController {
            // Present the view controller on the passed context.
            context.present(viewController, animated: true, completion: nil)
            print("presented")
        } else {
            print("Failed to present CourseListViewController")
        }
    }

    public func showContentDetail(from context: UIViewController, contentId: Int) {
        let contentDetailVC: ContentDetailViewController? = instantiateViewController(withIdentifier: "ContentDetailViewController")
        contentDetailVC?.contentId = contentId
        contentDetailVC?.modalPresentationStyle = .fullScreen
        presentViewController(contentDetailVC, from: context)
    }
    
    private func instantiateViewController<T>(withIdentifier identifier: String) -> T? {
        print("=========================instatitate start============")
        print(identifier)
        let storyboard = UIStoryboard(name: "Course", bundle: Bundle(for: TestpressCourse.self))
        print(storyboard)
        print("=========================instatitate end============")
        print(storyboard.instantiateViewController(withIdentifier: identifier))
        if let viewController = storyboard.instantiateViewController(withIdentifier: identifier) as? T {
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
