//
//  ProfileViewController.swift
//  ios-app
//
//  Copyright © 2017 Testpress. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Kingfisher
import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIStackView!
    @IBOutlet weak var tabBar: UITabBarItem!
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var testsTaken: UILabel!
    @IBOutlet weak var speed: UILabel!
    @IBOutlet weak var accuracy: UILabel!
    
    var activityIndicator: UIActivityIndicatorView? // Progress bar
    var emptyView: EmptyView!
    var user: User?
    var loading: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emptyView = EmptyView.getInstance(parentView: contentView)
        UIUtils.setButtonDropShadow(logoutButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if user == nil && !loading {
            getProfile()
        }
    }
    
    func getProfile() {
        loading = true
        activityIndicator = UIUtils.initActivityIndicator(parentView: contentView)
        activityIndicator?.center = CGPoint(x: contentView.center.x, y: contentView.center.y)
        activityIndicator?.startAnimating()
        TPApiClient.getProfile(
            endpointProvider: TPEndpointProvider(.getProfile),
            completion: {
                user, error in
                if let error = error {
                    debugPrint(error.message ?? "No error")
                    debugPrint(error.kind)
                    var retryHandler: (() -> Void)?
                    if error.kind == .network {
                        retryHandler = {
                            self.emptyView.hide()
                            self.getProfile()
                        }
                    }
                    if (self.activityIndicator?.isAnimating)! {
                        self.activityIndicator?.stopAnimating()
                    }
                    let (image, title, description) = error.getDisplayInfo()
                    self.emptyView.show(image: image, title: title, description: description,
                                        retryHandler: retryHandler)
                    
                    self.loading = false
                    return
                }
                
                self.displayProfileDetails(user: user!)
            }
        )
    }
    
    func displayProfileDetails(user: User) {
        self.user = user
        imageView.kf.setImage(with: URL(string: user.largeImage!),
                              placeholder: Images.ProfileImagePlaceHolder.image)
        
        if ((user.displayName) != nil) {
            usernameLabel.text = user.displayName
        } else {
            usernameLabel.text = user.username
        }
        score.text = user.score
        testsTaken.text = String(user.testsCount!)
        speed.text = String(user.averageSpeed!)
        accuracy.text = "\(user.averageAccuracy!)%"
        activityIndicator?.stopAnimating()
        loading = false
    }
    
    @IBAction func logout(_ sender: UIButton) {
        let alert = UIAlertController(title: nil,
                                      message: Strings.LOGOUT_CONFIRM_MESSAGE,
                                      preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(
            title: Strings.YES,
            style: UIAlertActionStyle.destructive,
            handler: { action in
                
                KeychainTokenItem.clearKeychainItems()
                let loginViewController = self.storyboard?.instantiateViewController(withIdentifier:
                    Constants.LOGIN_VIEW_CONTROLLER) as! LoginViewController
                
                self.present(loginViewController, animated: true, completion: nil)
            }
        ))
        alert.addAction(UIAlertAction(title: Strings.CANCEL, style: UIAlertActionStyle.cancel))
        present(alert, animated: true)
    }
    
    // Set frames of the views in this method to support both portrait & landscape view
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Set scroll view content height to support the scroll
        scrollView.contentSize.height = contentView.frame.size.height
    }
    
}
