//
//  VideoConferenceViewController.swift
//  ios-app
//
//  Copyright © 2020 Testpress. All rights reserved.
//

import UIKit

class VideoConferenceViewController: UIViewController {
    var content: Content!
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var contentDescription: UILabel!
    
    override func viewDidLoad() {
        displayTitleAndDescription()
        displayVideoConferenceDetails(content.videoConference)
    }

    func displayTitleAndDescription() {
        titleView.text = content.name
        contentDescription.text = content.contentDescription

        if content.contentDescription.isNilOrEmpty {
            contentDescription.isHidden = true
        }
    }
    
    func displayVideoConferenceDetails(videoConference: VideoConference) {
        duration.text = String(videoConference.duration)
        startDate.text = FormatDate.getDate(from: videoConference.start, givenFormat: "dd-MM-yyyy")
        startTime.text = FormatDate.getDate(from: videoConference.start, givenFormat: "hh:mm a")
    }

    @IBAction func openZoomMeeting(_ sender: Any?) {
        let storyboard = UIStoryboard(name: Constants.CHAPTER_CONTENT_STORYBOARD, bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: Constants.ZOOM_MEET_VIEW_CONTROLLER)
            as! ZoomMeetViewController
        viewController.accessToken = content.videoConference?.accessToken
        viewController.meetingNumber = content.videoConference?.conferenceId
        viewController.password = content.videoConference?.password
        viewController.meetingTitle = content.name
        viewController.fetchAccessToken = { completion in
            self.updateContent(completion: completion)
        }
        self.present(viewController, animated: true, completion: nil)
    }
    
    
    func updateContent(completion: @escaping(String?, TPError?) -> Void) {
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
