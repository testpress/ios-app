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
            InstituteRepository.shared.getSettings(refresh: true, completion: { _, _ in})
        }
    }
    
    public func initializeDB() {
        DBConnection.configure()
    }

    public func getMyCoursesViewController() -> CoursesTableViewController? {
        return instantiateViewController(withIdentifier: "CoursesTableViewController")
    }

    public func getContentDetailViewController(contentId: Int) -> ContentDetailPageViewController? {
        return nil
    }

    private func instantiateViewController<T>(withIdentifier identifier: String) -> T? {
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
