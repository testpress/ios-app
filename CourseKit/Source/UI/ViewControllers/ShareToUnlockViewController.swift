//
//  ShareToUnlockViewController.swift
//  ios-app
//
//  Created by Karthik on 23/03/20.
//  Copyright © 2020 Testpress. All rights reserved.
//

import UIKit

class ShareToUnlockViewController: BaseUIViewController {
    var shareText: String = ""
    var onShareCompletion: (() -> Void)?
    
    @IBOutlet weak var shareButton: UIButton!
    
    
    override func viewDidLoad() {
        self.setStatusBarColor()
        shareButton.setTitleColor(Colors.getRGB(Colors.PRIMARY_TEXT), for: .normal)
        shareButton.backgroundColor = TestpressCourse.shared.primaryColor
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func share(_ sender: UIButton) {
        let activityViewController = UIActivityViewController(activityItems:
            [shareText], applicationActivities: nil)
        let excludeActivities = [
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToTencentWeibo,
            UIActivity.ActivityType.airDrop,
            UIActivity.ActivityType.copyToPasteboard
        ]
        activityViewController.excludedActivityTypes = excludeActivities;
        activityViewController.popoverPresentationController?.sourceView = sender
        activityViewController.completionWithItemsHandler = {(activityType:
            UIActivity.ActivityType?, completed: Bool, returnedItems:[Any]?, error: Error?) in
            if (completed) {
                self.onShareCompletion?()
            }
        }
        self.present(activityViewController, animated: true,
                     completion: nil)
        
    }
}
