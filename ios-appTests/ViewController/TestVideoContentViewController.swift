//
//  TestVideoContentViewController.swift
//  ios-appTests
//
//  Created by Karthik raja on 11/25/19.
//  Copyright © 2019 Testpress. All rights reserved.
//

import XCTest

import ObjectMapper
import AVFoundation


@testable import ios_app

class TestVideoContentViewController: XCTestCase {
    let appDelegate = AppDelegate();
    var content:Content?
    
    var controller: VideoContentViewController?
    
    
    override func setUp() {
        super.setUp()
        
        let jsonString = "{`order`:0,`exam`:null,`practice`:null,`html_content_title`:null,`html_content_url`:`https://sandbox.testpress.in/api/v2.2.1/contents/190/html/`,`url`:`https://sandbox.testpress.in/api/v2.2.1/contents/190/`,`modified`:`2019-11-25T04:02:18.028173Z`,`attempts_url`:`https://sandbox.testpress.in/api/v2.2.1/contents/190/attempts/`,`chapter_id`:87,`chapter_slug`:`video`,`chapter_url`:`https://sandbox.testpress.in/api/v2.2.1/chapters/video/`,`id`:190,`video`:{`title`:`Test Video`,`url`:`https://secure.testpress.in/institute/sandbox/courses/test-course/videos/transcoded/c4bc4f3838a94c6592fd82d07d90c2f6/video.mp4?token=pnk4wvog2MJPm83R8iqhtw&expires=1574747643`,`id`:78,`embed_code`:``,`is_domain_restricted`:false},`name`:`Test Video`,`image`:`https://media.testpress.in/static/img/videoicon.png`,`attachment`:null,`description`:`lorem ipsum dolor sit amet`,`is_locked`:false,`attempts_count`:0,`start`:null,`end`:null,`has_started`:true,`active`:true,`bookmark_id`:null,`video_watched_percentage`:null}".replacingOccurrences(of: "`", with: "\"")
        content = Content(JSONString: jsonString)
        
        let storyboard = UIStoryboard(name: Constants.CHAPTER_CONTENT_STORYBOARD, bundle: nil)
        
        controller = storyboard.instantiateViewController(withIdentifier:
            Constants.VIDEO_CONTENT_VIEW_CONTROLLER) as? VideoContentViewController
        controller?.content = content
        let window = UIWindow()
        window.rootViewController = controller
        window.makeKeyAndVisible()
    }
    
    func testLabels() {
        XCTAssertEqual(controller?.titleLabel.text, content?.video?.title)
        XCTAssertEqual(controller?.desc.text, content?.description)
    }
    
    func testPlayer() {
        XCTAssertEqual(controller?.playerViewController.player?.rate, 1)
    }
    
    func testSubviews() {
        XCTAssertTrue(controller!.view.subviews.contains(controller!.playerViewController.view))
    }
}
