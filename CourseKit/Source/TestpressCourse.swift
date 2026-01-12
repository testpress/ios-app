import UIKit
import TPStreamsSDK


public class TestpressCourse {
    public static let shared = TestpressCourse()
    
    public static let bundle: Bundle = {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle(for: TestpressCourse.self)
        #endif
    }()

    private init() {}
    
    public var primaryColor: UIColor!
    public var statusBarColor: UIColor!
    
    public var subdomain: String!
    public var baseURL: String! {
        guard let subdomain = subdomain else { return nil }
        // return "https://\(subdomain).testpress.in"

        // return "https://process-syndrome-statements-guy.trycloudflare.com"
        return "https://1db8eef2b7a9.ngrok-free.app"
    }
    
    
    public func initialize(withToken token: String? = nil, subdomain: String, primaryColor: String, statusBarColor: String? = nil) {
        self.subdomain = subdomain
        self.primaryColor = Colors.getRGB(primaryColor)
        self.statusBarColor = Colors.getRGB(statusBarColor ?? primaryColor)

        initializeDB()
        
        if let token = token {
            saveTokenToKeychain(token: token)
            InstituteRepository.shared.getSettings(refresh: true, completion: { _, _ in})
        }
        
        if (KeychainTokenItem.isExist()) {
            let token: String = KeychainTokenItem.getToken()
            TPStreamsSDK.initialize(for : Provider.testpress, withOrgCode: subdomain, usingAuthToken: token)
        }
        FontRegistrar.registerRubikFonts()
    }
    
    public func initializeDB() {
        DBConnection.configure()
    }

    public func getMyCoursesViewController() -> CoursesTableViewController? {
        return instantiateViewController(withIdentifier: "CoursesTableViewController")
    }
    
    public func getMyCoursesViewController(tags: [String] = []) -> CoursesTableViewController? {
        let coursesTableViewController = instantiateViewController(withIdentifier: "CoursesTableViewController") as CoursesTableViewController?
        coursesTableViewController?.tags = tags
        return coursesTableViewController
    }
    
    public func getMyCoursesViewController(excludeTags: [String] = []) -> CoursesTableViewController? {
        let coursesTableViewController = instantiateViewController(withIdentifier: "CoursesTableViewController") as CoursesTableViewController?
        coursesTableViewController?.excludeTags = excludeTags
        return coursesTableViewController
    }

    public func getContentDetailViewController(contentId: Int) -> ContentDetailPageViewController? {
        guard let detailViewController: ContentDetailPageViewController = instantiateViewController(withIdentifier: Constants.CONTENT_DETAIL_PAGE_VIEW_CONTROLLER) else {
            return nil
        }
        
        detailViewController.contentId = contentId
        return detailViewController
    }
    
    public func getCourseDetailViewController(courseId: Int) -> ChaptersViewController? {
        guard let detailViewController: ChaptersViewController = instantiateViewController(withIdentifier: Constants.CHAPTERS_VIEW_CONTROLLER) else {
            return nil
        }
        
        detailViewController.courseId = courseId
        detailViewController.allowCustomTestGeneration = false
        return detailViewController
    }
    
    public func getPaymentPageViewController() -> UIViewController? {
        return instantiateViewController(withIdentifier: "ComingSoonViewController")
    }
    
    public func getMyDownloadsViewController() -> UIViewController? {
        return instantiateViewController(withIdentifier: Constants.OFFLINE_DOWNLOADS_VIEW_CONTROLLERS)
    }

    private func instantiateViewController<T>(withIdentifier identifier: String) -> T? {
        let storyboard = UIStoryboard(name: "Course", bundle: TestpressCourse.bundle)
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
