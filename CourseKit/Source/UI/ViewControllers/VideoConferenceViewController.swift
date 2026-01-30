//
//  VideoConferenceViewController.swift
//  ios-app
//
//  Copyright © 2020 Testpress. All rights reserved.
//

import UIKit

class VideoConferenceViewController: BaseUIViewController {
    var content: Content!
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var contentDescription: UILabel!
    
    override func viewDidLoad() {
        displayTitleAndDescription()
        displayVideoConferenceDetails()
    }
    
    func displayTitleAndDescription() {
        titleView.text = content.name
        contentDescription.text = content.contentDescription
        
        if content.contentDescription.isNilOrEmpty {
            contentDescription.isHidden = true
        }
    }
    
    func displayVideoConferenceDetails() {
        let videoConference = content.videoConference!
        duration.text = String(videoConference.duration)
        startDate.text = FormatDate.format(dateString: videoConference.start, requiredFormat: "dd-MM-yyyy")
        startTime.text = FormatDate.utcToLocalTime(dateStr: FormatDate.format(dateString: videoConference.start, requiredFormat: "hh:mm ss"))
    }
    
    @IBAction func openZoomMeeting(_ sender: Any?) {
// // //         let storyboard = UIStoryboard(name: Constants.CHAPTER_CONTENT_STORYBOARD, bundle: TestpressCourse.bundle)
// // //         let viewController = storyboard.instantiateViewController(
// // //             withIdentifier: Constants.ZOOM_MEET_VIEW_CONTROLLER)
// // //             as! ZoomMeetViewController
// // //         viewController.accessToken = content.videoConference?.accessToken
// // //         viewController.meetingNumber = content.videoConference?.conferenceId
// // //         viewController.password = content.videoConference?.password
// // //         viewController.meetingTitle = content.name
// // //         viewController.fetchAccessToken = { completion in
// // //             self.fetchAccessToken(completion: completion)
// // //         }
// // //         self.present(viewController, animated: true, completion: nil)
    }
    
    
    func fetchAccessToken(completion: @escaping(String?, TPError?) -> Void) {
        TPApiClient.request(
            type: Content.self,
            endpointProvider: TPEndpointProvider(.get, url: content.getUrl()),
            completion: {
                content, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                completion(content?.videoConference?.accessToken, nil)
        })
    }
}
