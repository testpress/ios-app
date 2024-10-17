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
        controller?.contents = [content!]
        let window = UIWindow()
        window.rootViewController = controller
        window.makeKeyAndVisible()
        controller?.viewDidLoad()
    }
    
    func testCustomView() {
        XCTAssertTrue(controller!.customView.isHidden)
        
        controller?.showWarning(text: "Stop casting")
        XCTAssertEqual(controller?.warningLabel.text, "Stop casting")
        XCTAssertFalse(controller!.customView.isHidden)
        XCTAssertTrue(controller!.videoPlayerView.isHidden)
        
        controller?.hideWarning()
        XCTAssertTrue(controller!.customView.isHidden)
        XCTAssertFalse(controller!.videoPlayerView.isHidden)
    }
    
    func testVideoPlayerView() {
        XCTAssertEqual(controller?.videoPlayerView.frame, CGRect(x:0, y:0, width:controller!.view.frame.width, height: controller!.videoPlayer.frame.height))
        
        controller?.videoPlayerView.fullScreen()
        XCTAssertEqual(controller?.videoPlayerView.frame, UIScreen.main.bounds)
    }
    
    func testAddOrRemoveBookmark() {
        controller!.addOrRemoveBookmark(content: controller?.content)
        XCTAssertTrue(UIApplication.topViewController()!.isKind(of: BookmarkFolderTableViewController.self))
    }
    
    func testNumberOfRows() {
        let tableView = UITableView()
        let numberOfRows = controller?.tableView(tableView, numberOfRowsInSection: 0)
        
        XCTAssertEqual(numberOfRows, controller?.contents.count)
    }
    
    func testRelatedContent() {
        let cell = controller!.tableView.dequeueReusableCell(withIdentifier: "RelatedContentsCell") as! RelatedContentsCell
        cell.initCell(index: 0, contents: (controller!.contents)!, viewController: controller!)
        
        XCTAssertEqual(cell.title.text, content?.name)
        XCTAssertEqual(cell.title.textColor, Colors.getRGB(Colors.DIM_GRAY))
        XCTAssertEqual(cell.desc.textColor, Colors.getRGB(Colors.DIM_GRAY))
        XCTAssertEqual(cell.contentIcon.imageColor, Colors.getRGB(Colors.DIM_GRAY))
        XCTAssertEqual(cell.bookmarkIcon.imageColor, Colors.getRGB(Colors.DIM_GRAY))
    }
    
    func testCurrentRelatedContent() {
        let cell = controller!.tableView.dequeueReusableCell(withIdentifier: "RelatedContentsCell") as! RelatedContentsCell
        cell.initCell(index: 0, contents: (controller!.contents)!, viewController: controller!, is_current: true)
        
        XCTAssertEqual(cell.title.textColor, Colors.getRGB(Colors.DODGERBLUE))
        XCTAssertEqual(cell.desc.textColor, Colors.getRGB(Colors.DODGERBLUE))
        XCTAssertEqual(cell.contentIcon.imageColor, Colors.getRGB(Colors.DODGERBLUE))
        XCTAssertEqual(cell.bookmarkIcon.imageColor, Colors.getRGB(Colors.DODGERBLUE))
        XCTAssertEqual(cell.desc.text, "Now Playing...")
    }
    
    func testPlaybackSpeedMenu() {
        controller!.showPlaybackSpeedMenu()
        let alertController = controller?.presentedViewController as? UIAlertController
        
        XCTAssertEqual(alertController?.title, "Playback Speed")
        XCTAssertEqual(alertController?.actions.count, PlaybackSpeed.allCases.count + 1)
    }
    
    func testOptionsMenu() {
        controller!.showOptionsMenu()
        let alertController = controller?.presentedViewController as? UIAlertController
        
        XCTAssertEqual(alertController?.title, nil)
        XCTAssertEqual(alertController?.actions.count, 3)
    }
    
    func testQualitySelectorMenu() {
        controller!.showQualitySelector()
        let alertController = controller?.presentedViewController as? UIAlertController
        
        XCTAssertEqual(alertController?.title, "Quality")
        XCTAssertEqual(alertController?.actions.count, 2)
    }
    
}
