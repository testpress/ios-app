import UIKit

#if SWIFT_PACKAGE
let bundle = Bundle.module
#else
let bundle = Bundle(for: TestpressCourse.self)
#endif

public class TestpressCourse {
    public static let shared = TestpressCourse()

    private init() {}
    
    public func initialize(withToken token: String? = nil){
        initializeDB()
        
        if let token = token {
            saveTokenToKeychain(token: token)
        }
    }
    
    public func initializeDB() {
        DBConnection.configure()
    }

    public func getMyCoursesViewController() -> CoursesTableViewController? {
        let viewController = instantiateViewController(withIdentifier: "CoursesTableViewController") as? CoursesTableViewController
        viewController?.title = "Learn"
        viewController?.tabBarItem.image = Images.LearnNavBarIcon.image
        viewController?.modalPresentationStyle = .fullScreen
        return viewController
    }

    public func getContentDetailViewController(contentId: Int) -> ContentDetailPageViewController? {
        return nil
    }

    private func instantiateViewController<T: UIViewController>(withIdentifier identifier: String) -> T? {
        let storyboard = UIStoryboard(name: "Course", bundle: bundle)
        return storyboard.instantiateViewController(withIdentifier: identifier) as? T
    }
    
    public func clearData() {
        DBConnection.clearTables()
    }
    
    private func saveTokenToKeychain(token: String) {
        do {
            let passwordItem = KeychainTokenItem(service: Constants.KEYCHAIN_SERVICE_NAME, account: "TestpressUser")
            try passwordItem.savePassword(token)
        } catch {
            fatalError("Error updating keychain - \(error)")
        }
    }
}
