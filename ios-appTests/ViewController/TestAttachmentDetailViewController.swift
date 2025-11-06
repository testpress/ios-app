//
//  TestAttachmentDetailViewController.swift
//  ios-appTests
//
//

import XCTest
@testable import ios_app

class TestAttachmentDetailViewController: XCTestCase {

    let appDelegate = AppDelegate()
    
    var controller: AttachmentDetailViewController!
    
    override func setUp() {
        let storyboard = UIStoryboard(name: Constants.CHAPTER_CONTENT_STORYBOARD, bundle: nil)
        controller = storyboard.instantiateViewController(withIdentifier:
            Constants.ATTACHMENT_DETAIL_VIEW_CONTROLLER) as? AttachmentDetailViewController
        controller.content = getContent()
        let window = UIWindow()
        window.rootViewController = controller
        window.makeKeyAndVisible()
    }
    
    func  getContent() -> Content {
    let jsonString = "{`order`:1,`exam`:null,`html_content_title`:null,`html_content_url`:`https://360.verandalearning.com/api/v2.3/contents/3737/html/`,`free_preview`:false,`url`:`https://360.verandalearning.com/api/v2.4/contents/3737/`,`modified`:`2020-12-21T22:01:45.445807Z`,`attempts_url`:`https://360.verandalearning.com/api/v2.3/contents/3737/attempts/`,`chapter_id`:1887,`chapter_slug`:`learning-unit-1total-number-of-person-in-a-row-2`,`chapter_url`:`https://360.verandalearning.com/api/v2.4/chapters/learning-unit-1total-number-of-person-in-a-row-2/`,`id`:3737,`video`:null,`name`:`Day 4-Number Ranking 1`,`image`:`https://static.testpress.in/static/img/fileicon.png`,`attachment`:{`title`:`Day 4-Number Ranking 1`,`attachment_url`:`https://attachment.testpress.in/institute/verandalearning/private/courses/13/attachments/4294a3e32b1841e5bae1c90b50760abe.pdf?Expires=1610170634&Signature=FjJZja55WwpWipY7X9ORJBIVwxj8gOQIx0OGf5ZuTOrMnd2T8PmrDvOLzKX91ntf5Ju3Q~XclmZVPt6WrAwJZJJwiyVg6RbX9paygG052MvPkP5tBZTH7y~C0BdSvQUXRjbqAbEP0A09PKTUMXIL762dU0cDg7P31xuQrD2AnbPd1lO4WmGOznoj9cDRrvS9p7UAf6~Q~G6nQQTV1LVZyhmB2zfhRijTrEtfq9wIb0kJwcGteKqBlkJMFSAKrz7VrZXVqW9i73Upd1BGXbXEIVefoJv8ZxmOFXAFpu-uc5DNFwbROJjmhBe-uZBvH7PLR7E0zm52vGC0B7EKvEE6lQ__&Key-Pair-Id=K2XWKDWM065EGO`,`description`:`<p>Total number of person in a row</p>`,`id`:1253,`is_renderable`:true},`description`:`<p>Total number of person in a row</p>`,`is_locked`:false,`attempts_count`:null,`start`:null,`end`:null,`has_started`:true,`content_type`:`Attachment`,`title`:`Day 4-Number Ranking 1`,`bookmark_id`:null,`html_content`:null,`active`:true,`comments_url`:`https://360.verandalearning.com/api/v2.3/contents/3737/comments/`,`wiziq`:null,`video_conference`:null,`course_id`:13,`is_course_available`:true,`cover_image`:null,`cover_image_medium`:null,`cover_image_small`:null,`next_content_id`:3738}".replacingOccurrences(of: "`", with: "\"")

        return  Content(JSONString: jsonString)!
    }


    func testDownloadButtonShouldBeHiddenIfContentIsRenderable() throws {
        controller.viewDidLoad()
        
        XCTAssertTrue(controller.downloadAttachmentButton.isHidden)
        XCTAssertFalse(controller.viewAttachmentButton.isHidden)
        XCTAssertTrue(controller.content.attachment!.isRenderable)
    }
    
    
    func testViewButtonShouldBeHiddenIfContentIsNotRenderable() throws {
        controller.content.attachment?.isRenderable = false
        controller.viewAttachmentButton.isHidden = true
        controller.downloadAttachmentButton.isHidden = true
        controller.viewDidLoad()
        
        XCTAssertFalse(controller.downloadAttachmentButton.isHidden)
        XCTAssertTrue(controller.viewAttachmentButton.isHidden)
    }
}
