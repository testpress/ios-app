////
////  ForumViewController.swift
////  ios-app
////
////  Copyright © 2017 Testpress. All rights reserved.
////
////  Permission is hereby granted, free of charge, to any person obtaining a copy
////  of this software and associated documentation files (the "Software"), to deal
////  in the Software without restriction, including without limitation the rights
////  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
////  copies of the Software, and to permit persons to whom the Software is
////  furnished to do so, subject to the following conditions:
////
////  The above copyright notice and this permission notice shall be included in
////  all copies or substantial portions of the Software.
////
////  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
////  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
////  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
////  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
////  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
////  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
////  THE SOFTWARE.
////
//
//import UIKit
//import CourseKit
//
//class ForumViewController: UIViewController, DiscussionFilterDelegate {
//    
//    @IBOutlet weak var searchBar: UISearchBar!
//    @IBOutlet weak var postCreateButton: UIButton!
//    @IBOutlet weak var containerView: UIView!
//    
//    let viewController = ForumFilterViewController()
//    var forumTableViewController: ForumTableViewController!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        viewController.delegate = self
//        self.searchBar.delegate = self
//        UIUtils.setButtonDropShadow(postCreateButton)
//    }
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "ForumListSegue" {
//            if let viewController =
//                segue.destination as? ForumTableViewController {
//                
//                self.forumTableViewController = viewController
//            }
//        }
//    }
//    
//    @IBAction func composePost(_ sender: Any) {
//        let storyboard = UIStoryboard(name: Constants.POST_STORYBOARD, bundle: nil)
//        let viewController = storyboard.instantiateViewController(withIdentifier:
//            Constants.POST_CREATION_VIEW_CONTROLLER) as! PostCreationViewController
//        
//        viewController.parentTableViewController = forumTableViewController
//        present(viewController, animated: true, completion: nil)
//    }
//    
//    func applyFilters(value: [String : Any]) {
//        self.forumTableViewController.filter(dict: value)
//    }
//    
//    
//    @IBAction func showProfileDetails(_ sender: UIBarButtonItem) {
//        UserHelper.showProfileDetails(self)
//    }
//    
//    @IBAction func onFilterButtonClick(_ sender: Any) {
//        present(viewController, animated: true, completion: nil)
//    }
//    
//}
//
//
//extension ForumViewController: UISearchBarDelegate {
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        Debounce<String>.input(searchText, delay: 0.5, current: searchBar.text ?? "") {_ in
//            self.forumTableViewController.search(searchString: searchText)
//        }
//    }
//    
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        self.forumTableViewController.search(searchString: "")
//    }
//}
