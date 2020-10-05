//
//  TestVideoConferenceViewController.swift
//  ios-appTests
//
//  Created by Karthik on 05/10/20.
//  Copyright © 2020 Testpress. All rights reserved.
//

import XCTest
@testable import ios_app

class TestVideoConferenceViewController: XCTestCase {
    let appDelegate = AppDelegate()
    
    var controller: VideoConferenceViewController!
    
    override func setUp() {
        let storyboard = UIStoryboard(name: Constants.CHAPTER_CONTENT_STORYBOARD, bundle: nil)
        controller = storyboard.instantiateViewController(withIdentifier:
            Constants.VIDEO_CONFERENCE_VIEW_CONTROLLER) as? VideoConferenceViewController
        controller.content = getContent()
        let window = UIWindow()
        window.rootViewController = controller
        window.makeKeyAndVisible()
    }
    
    func getContent() -> Content {
        let jsonString = "{`order`:0,`exam`:null,`html_content_title`:null,`html_content_url`:`https://sandbox.testpress.in/api/v2.3/contents/287/html/`,`free_preview`:false,`url`:`https://sandbox.testpress.in/api/v2.4/contents/287/`,`modified`:`2020-07-07T09:11:53.166762Z`,`attempts_url`:`https://sandbox.testpress.in/api/v2.3/contents/287/attempts/`,`chapter_id`:115,`chapter_slug`:`meetings-2`,`chapter_url`:`https://sandbox.testpress.in/api/v2.4/chapters/meetings-2/`,`id`:287,`video`:null,`name`:null,`image`:`https://static.testpress.in/static/img/live_conference.png`,`attachment`:null,`description`:``,`is_locked`:false,`attempts_count`:null,`start`:null,`end`:null,`has_started`:true,`content_type`:`VideoConference`,`title`:`My Zoom Meet`,`bookmark_id`:null,`html_content`:null,`active`:true,`comments_url`:`https://sandbox.testpress.in/api/v2.3/contents/287/comments/`,`wiziq`:null,`video_conference`:{`id`:2,`title`:`My Zoom Meet`,`conference_id`:`95873251598`,`start`:`2020-07-07T09:30:00Z`,`duration`:60,`provider`:`Zoom`,`join_url`:`https://sandbox.testpress.in/embed/zoom-meeting/2/`,`password`:`5AH7HL`,`access_token`:`eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBLZXkiOiJIWUtJeTRwREhhTjNBalB1d2pRVWdnajhsdVpxNmNEeWladGIiLCJpYXQiOjE2MDE4ODc2NzcsInRva2VuRXhwIjoxNjAxOTc0MDc3LCJleHAiOjE2MDE5NzQwNzd9.O82c9Xk0LlTfTD2tD3kCMRYCiE88UKjlj7Y3EiBtAeg`},`course_id`:67,`is_course_available`:true}".replacingOccurrences(of: "`", with: "\"")
        return Content(JSONString: jsonString)!
    }

    func testDisplayShouldShowVideoConferenceDetails() {
        controller.display()
        
        XCTAssertEqual(controller.titleView.text, "My Zoom Meet")
        XCTAssertEqual(controller.startTime.text, "03:00 PM")
        XCTAssertEqual(controller.startDate.text, "07-07-2020")
        XCTAssertEqual(controller.duration.text, "60")
    }
    
    func testOnStartButtonClickZoomMeetViewShouldOpen() {
        controller.onStartClick(nil)
        
        XCTAssertTrue(UIApplication.topViewController()!.isKind(of: ZoomMeetViewController.self))
    }
}
