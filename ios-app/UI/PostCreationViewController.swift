//
//  PostCreationViewController.swift
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

import Alamofire
import TTGSnackbar
import UIKit

class PostCreationViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource,
    UITextViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var postTitle: UITextView!
    @IBOutlet weak var postContent: UITextView!
    @IBOutlet weak var categoryPickerView: UIPickerView!
    @IBOutlet weak var pickTopicLayout: UIStackView!
    
    var postCreated: Bool = false
    var parentTableViewController: TPBasePagedTableViewController<Post>!
    var emptyView: EmptyView!
    let loadingDialogController = UIUtils.initProgressDialog(message: Strings.PLEASE_WAIT + "\n\n")
    let pickerViewItems = ["Doubt", "Knowledge sharing", "Other"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryPickerView.delegate = self
        categoryPickerView.dataSource = self
        postContent.delegate = self
        categoryPickerView.selectRow(1, inComponent: 0, animated: false)
        emptyView = EmptyView.getInstance(parentView: contentView)
        pickTopicLayout.isHidden = true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerViewItems.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int,
                    reusing view: UIView?) -> UIView {
        
        var label = UILabel()
        if let v = view {
            label = v as! UILabel
        }
        label.font = UIFont (name: "Rubik", size: 14)
        label.text =  pickerViewItems[row]
        label.textAlignment = .center
        return label
    }
    
    @IBAction func publishPost(_ sender: Any) {
        postTitle.resignFirstResponder()
        postContent.resignFirstResponder()
        let title: String! = postTitle.text
        let content: String! = postContent.text
        if title == nil || title.elementsEqual("") || content == nil || content.elementsEqual("") {
            return
        }
        present(loadingDialogController, animated: true)
        let endpoint = TPEndpointProvider(.createForumPost)
        let parameters: Parameters = ["title": title, "content_html": content]
        TPApiClient.request(type: Post.self, endpointProvider: endpoint, parameters: parameters,
            completion: { post, error in
                
                if let error = error {
                    debugPrint(error.message ?? "No error")
                    debugPrint(error.kind)
                    self.loadingDialogController.dismiss(animated: false)
                    let (_, title, _) = error.getDisplayInfo()
                    TTGSnackbar(message: title, duration: .middle).show()
                    return
                }
                
                self.postTitle.text = nil
                self.postContent.text = nil
                self.loadingDialogController.dismiss(animated: false)
                self.postCreated = true
                self.emptyView.show(
                    image: Images.SuccessTick.image,
                    title: Strings.YOU_MADE_IT,
                    description: Strings.POST_CREATED_DESCRIPTION,
                    retryButtonText: Strings.OK,
                    retryHandler: self.back
                )
        })
    }
    
    override func viewDidLayoutSubviews() {
        // Set scroll view content height to support the scroll
        let height = contentStackView.frame.size.height
        if contentViewHeightConstraint.constant < height {
            contentViewHeightConstraint.constant = height
            scrollView.contentSize.height = height
            contentView.layoutIfNeeded()
        }
    }
    
    @IBAction func back() {
        parentTableViewController.dismiss(animated: false, completion: {
            if self.postCreated {
                self.parentTableViewController.items.removeAll()
            }
        })
    }
    
}
