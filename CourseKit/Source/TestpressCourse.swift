import UIKit

#if SWIFT_PACKAGE
let bundle = Bundle.module
#else
let bundle = Bundle(for: TestpressCourse.self)
#endif

public class TestpressCourse {
    public static let shared = TestpressCourse()

    private init() {}
    
    public var primaryColor: UIColor!
    
    public var subdomain: String!
    public var baseURL: String! {
        guard let subdomain = subdomain else { return nil }
        return "https://\(subdomain).testpress.in"
    }
    
    
    public func initialize(withToken token: String? = nil, subdomain: String, primaryColor: String) {
        self.subdomain = subdomain
        self.primaryColor = Colors.getRGB(primaryColor)

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
        detailViewController.baseUrl = TPEndpointProvider.getCourseDetailUrl(courseId: courseId)
        detailViewController.allowCustomTestGeneration = false
        return detailViewController
    }
    
    public func getPaymentPageViewController() -> UIViewController? {
        return instantiateViewController(withIdentifier: "ComingSoonViewController")
    }
    
    public func getMyDownloadsViewController() -> UIViewController? {
        return instantiateViewController(withIdentifier: "ComingSoonViewController")
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
