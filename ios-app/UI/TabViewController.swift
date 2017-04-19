//
//  TabViewController.swift
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

import UIKit
import XLPagerTabStrip

class TabViewController: ButtonBarPagerTabStripViewController {
    
    @IBOutlet weak var tempButtonBarView: ButtonBarView!
    @IBOutlet weak var tempContainerView: UIScrollView!
    
    let blueInstagramColor = UIColor(red: 37/255.0, green: 111/255.0, blue: 206/255.0, alpha: 1.0)

    override func viewDidLoad() {
        
        self.buttonBarView = self.tempButtonBarView
        self.containerView = self.tempContainerView
        
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = blueInstagramColor
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 14)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?,
            newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool,
            animated: Bool) -> Void in
            
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .black
            newCell?.label.textColor = self?.blueInstagramColor
        }
        
        super.viewDidLoad()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)?) {
        super.dismiss(animated: flag, completion:completion)
        // When user returns after attempted(paused or end) an exam, move to history tab &
        // refresh the list items
        if currentIndex != 2 {
            moveToViewController(at: 2, animated: true)
        }
        reloadPagerTabStripView()
    }
    
    // MARK: - PagerTabStripDataSource
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let available = ExamsTableViewController(state: .available)
        let upcoming = ExamsTableViewController(state: .upcoming)
        let history = ExamsTableViewController(state: .history)
        return [available, upcoming, history]
    }
    
    // MARK: - Custom Action

    @IBAction func logout(_ sender: UIBarButtonItem) {
        for passwordItem in KeychainTokenItem.passwordItems() {
            do {
                try passwordItem.deleteItem()
            } catch {
                fatalError("Error deleting keychain item - \(error)")
            }
        }
        
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier:
            Constants.LOGIN_VIEW_CONTROLLER) as! LoginViewController
        self.present(loginViewController, animated: true, completion: nil)
    }
    
}
