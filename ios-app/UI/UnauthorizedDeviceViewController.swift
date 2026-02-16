//
//  UnauthorizedDeviceViewController.swift
//  ios-app
//
//  Created by Testpress on 07/10/24.
//  Copyright © 2024 Testpress. All rights reserved.
//

import UIKit

class UnauthorizedDeviceViewController: UIViewController {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var actionHandler: (() -> Void)?
    var errorMessage: String?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        descriptionLabel.text = errorMessage
    }
    
    @IBAction func onActionTapped(_ sender: UIButton) {
        actionHandler?()
    }
}
