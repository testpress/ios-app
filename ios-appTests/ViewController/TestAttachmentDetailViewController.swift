//
//  TestAttachmentDetailViewController.swift
//  ios-appTests
//
//

import XCTest
@testable import ios_app
import PDFReader

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
    
    func getPDFData() -> String {
        return "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NK0r0dNeb7lrelZWeE2Hc4s2Vcdl6dyidXRS0WnxoG3raTe3yJk9L8tcmOPenUjdLnL69nIn0qooC3KSc31zPe3uRHLilrLqgX7gZt3quKwXkBXiZ3Ty2gW08s5fuwIA+N/4FzXa5bcKZW5kc3RyZWFtCmVuZG9iago3IDAgb2JqCjw8L0ZpbHRlciAvRmxhdGVEZWNvZGUgL0xlbmd0aCAzNiA+PnN0cmVhbQp4nGOY+T9+///5N/7f//QfCPY//S+/9L/9pv/1Z/4DABnxFJkKZW5kc3RyZWFtCmVuZG9iagoyIDAgb2JqCjw8Ci9Qcm9jU2V0IFsvUERGIC9UZXh0IC9JbWFnZUIgL0ltYWdlQyAvSW1hZ2VJXQovRm9udCA8PAo+PgovWE9iamVjdCA8PAovVFBMMSA1IDAgUgo+Pgo+PgplbmRvYmoKOCAwIG9iago8PAovQ3JlYXRvciAoT25saW5lMlBERi5jb20pCi9Qcm9kdWNlciAoT25saW5lMlBERi5jb20pCi9DcmVhdGlvbkRhdGUgKEQ6MjAyMTAxMjkxMjU3MTQrMDEnMDAnKQo+PgplbmRvYmoKOSAwIG9iago8PAovVHlwZSAvQ2F0YWxvZwovUGFnZXMgMSAwIFIKL09wZW5BY3Rpb24gWzMgMCBSIC9GaXRIIG51bGxdCi9QYWdlTGF5b3V0IC9PbmVDb2x1bW4KPj4KZW5kb2JqCnhyZWYKMCAxMAowMDAwMDAwMDAwIDY1NTM1IGYgCjAwMDAwMDAyMjcgMDAwMDAgbiAKMDAwMDAwMjAyNyAwMDAwMCBuIAowMDAwMDAwMDA5IDAwMDAwIG4gCjAwMDAwMDAwODcgMDAwMDAgbiAKMDAwMDAwMDMxNCAwMDAwMCBuIAowMDAwMDAwNjUxIDAwMDAwIG4gCjAwMDAwMDE5MjIgMDAwMDAgbiAKMDAwMDAwMjEzMyAwMDAwMCBuIAowMDAwMDAyMjQ3IDAwMDAwIG4gCnRyYWlsZXIKPDwKL1NpemUgMTAKL1Jvb3QgOSAwIFIKL0luZm8gOCAwIFIKL0lEIFs8NTlEMjRFMUNENjBCMzg3OTk3RUZDM0I3RjhBRDFERTE+PDU5RDI0RTFDRDYwQjM4Nzk5N0VGQzNCN0Y4QUQxREUxPl0KPj4Kc3RhcnR4cmVmCjIzNTAKJSVFT0YK"
    }
    
    func testWatermarkShouldBeInitialized() {
        let pdfDoc = PDFDocument(fileData:Data(base64Encoded: getPDFData())!, fileName: "esv")
        controller.displayPdf(pdfDoc)
        
        XCTAssertTrue(controller.watermarkLabel!.text!.contains("testpress"))
    }
    
    func testMoveWatermarkShouldChangeWatermarkPosition() {
        let pdfDoc = PDFDocument(fileData:Data(base64Encoded: getPDFData())!, fileName: "esv")
        controller.displayPdf(pdfDoc)
        let initialPosition = controller.watermarkLabel?.frame
        
        controller.moveWatermarkPosition()
        XCTAssertNotEqual(initialPosition, controller.watermarkLabel?.frame)
    }
}
