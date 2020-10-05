//
//  VideoConferenceViewController.swift
//  ios-app
//
//  Created by Karthik on 15/09/20.
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
        display()
    }
    
    func display() {
        self.modalPresentationStyle = .fullScreen
        titleView.text = content.name
        if content.contentDescription.isNilOrEmpty {
            contentDescription.isHidden = true
        } else {
            contentDescription.text = content.contentDescription
        }
        let videoConference = content.videoConference
        duration.text = String(videoConference!.duration)
        displayTime(videoConference: videoConference!)
    }
    
    
    func displayTime(videoConference: VideoConference) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        formatter.timeZone = TimeZone(identifier: "IST")
        if let date = FormatDate.getDate(from: videoConference.start) {
            startDate.text = formatter.string(from: date)
        }
        formatter.dateFormat = "hh:mm a"
        if let time = FormatDate.getDate(from: videoConference.start) {
            startTime.text = formatter.string(from: time)
        }
    }
    
    @IBAction func onStartClick(_ sender: Any?) {
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
        UIApplication.topViewController()?.present(viewController, animated: true, completion: nil)
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
