import UIKit

public class TestpressCourse {
    public static let shared = TestpressCourse()

    private init() {}

    public func showMyCourses(from context: UIViewController) {
        print("CALLED")
        let storyboardName = "Course"
            let storyboardID = "CourseListViewController"
            let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
            
            print("Attempting to load storyboard with name: \(storyboardName)")
            
            if let viewController = storyboard.instantiateViewController(withIdentifier: storyboardID) as? CourseListViewController {
                print("Successfully instantiated CourseListViewController")
                context.present(viewController, animated: true, completion: nil)
                print("presented")
            } else {
                print("Failed to instantiate CourseListViewController with ID: \(storyboardID)")
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
